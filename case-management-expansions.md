# Extended Case Management Components Guide

## 1. KPI Calculations - Brief Overview

KPIs in case management typically track:
- Average resolution time
- Cases by status/priority
- SLA compliance rates
- Agent performance metrics
- Customer satisfaction scores

These are calculated using SharePoint list data and can be displayed using Power BI or custom SPFx components.

## 2. Power Automate Flow Templates

### A. Case Assignment Flow
```json
{
    "definition": {
        "triggers": {
            "when_case_created": {
                "type": "SharePointTrigger",
                "inputs": {
                    "list": "Cases",
                    "site": {
                        "url": "https://yourtenant.sharepoint.com/sites/casemanagement"
                    },
                    "triggerConditions": {
                        "status": "eq 'New'"
                    }
                }
            }
        },
        "actions": {
            "get_case_details": {
                "type": "SharePointReadOperation",
                "inputs": {
                    "list": "Cases",
                    "id": "@triggerBody()?['ID']"
                }
            },
            "determine_assignment": {
                "type": "Compose",
                "inputs": {
                    "assignmentLogic": {
                        "if": "@equals(outputs('get_case_details')?['Priority'], 'High')",
                        "then": {
                            "team": "Senior Agents",
                            "sla": "4 hours"
                        },
                        "else": {
                            "team": "Standard Agents",
                            "sla": "24 hours"
                        }
                    }
                }
            },
            "get_available_agent": {
                "type": "Http",
                "inputs": {
                    "method": "GET",
                    "uri": "/_api/web/lists/getbytitle('Agents')/items",
                    "headers": {
                        "Accept": "application/json;odata=verbose"
                    },
                    "queries": {
                        "$filter": "Status eq 'Available' and Team eq '@{outputs('determine_assignment')?['team']}'"
                    }
                }
            },
            "assign_case": {
                "type": "SharePointUpdateOperation",
                "inputs": {
                    "list": "Cases",
                    "id": "@triggerBody()?['ID']",
                    "item": {
                        "AssignedTo": "@outputs('get_available_agent')?['Id']",
                        "Status": "Assigned",
                        "DueDate": "@addToTime(utcNow(), outputs('determine_assignment')?['sla'])"
                    }
                }
            },
            "create_teams_task": {
                "type": "Teams.CreateTask",
                "inputs": {
                    "title": "New Case Assignment: @{triggerBody()?['CaseNumber']}",
                    "assignedTo": "@outputs('get_available_agent')?['Email']",
                    "dueDate": "@outputs('assign_case')?['DueDate']"
                }
            }
        }
    }
}
```

### B. SLA Monitoring Flow
```json
{
    "definition": {
        "triggers": {
            "schedule": {
                "type": "Recurrence",
                "inputs": {
                    "frequency": "Hour",
                    "interval": 1
                }
            }
        },
        "actions": {
            "get_active_cases": {
                "type": "SharePointReadOperation",
                "inputs": {
                    "list": "Cases",
                    "filter": "Status ne 'Closed' and Status ne 'Resolved'"
                }
            },
            "check_sla_status": {
                "type": "Foreach",
                "foreach": "@outputs('get_active_cases')?['value']",
                "actions": {
                    "calculate_time_remaining": {
                        "type": "Compose",
                        "inputs": "@subtractFromTime(items('check_sla_status')?['DueDate'], utcNow(), 'Hour')"
                    },
                    "condition_sla_breach": {
                        "type": "If",
                        "conditions": "@less(outputs('calculate_time_remaining'), 2)",
                        "actions": {
                            "send_urgent_notification": {
                                "type": "SendEmail",
                                "inputs": {
                                    "to": "@items('check_sla_status')?['AssignedTo']?['Email']",
                                    "subject": "⚠️ SLA Breach Alert - Case @{items('check_sla_status')?['CaseNumber']}",
                                    "body": "Case is approaching SLA breach. Time remaining: @{outputs('calculate_time_remaining')} hours"
                                }
                            },
                            "update_case_priority": {
                                "type": "SharePointUpdateOperation",
                                "inputs": {
                                    "list": "Cases",
                                    "id": "@items('check_sla_status')?['ID']",
                                    "item": {
                                        "Priority": "High",
                                        "SLAStatus": "At Risk"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
```

## 3. SPFx Web Part Examples

### A. Case Dashboard Web Part
```typescript
import * as React from 'react';
import { useState, useEffect } from 'react';
import { SPHttpClient, SPHttpClientResponse } from '@microsoft/sp-http';
import { WebPartContext } from '@microsoft/sp-webpart-base';
import { Card, CardHeader, CardContent } from '@/components/ui/card';
import { Alert } from '@/components/ui/alert';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';

interface ICaseDashboardProps {
  context: WebPartContext;
  listName: string;
}

interface ICase {
  Id: number;
  Title: string;
  CaseNumber: string;
  Status: string;
  Priority: string;
  AssignedTo: {
    Title: string;
    Email: string;
  };
  Created: string;
  DueDate: string;
}

const CaseDashboard: React.FC<ICaseDashboardProps> = (props) => {
  const [cases, setCases] = useState<ICase[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string>('');

  useEffect(() => {
    fetchCases();
  }, []);

  const fetchCases = async (): Promise<void> => {
    try {
      const response = await props.context.spHttpClient.get(
        `${props.context.pageContext.web.absoluteUrl}/_api/web/lists/getbytitle('${props.listName}')/items?$select=Id,Title,CaseNumber,Status,Priority,AssignedTo/Title,AssignedTo/Email,Created,DueDate&$expand=AssignedTo`,
        SPHttpClient.configurations.v1
      );

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      setCases(data.value);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const renderCaseTable = (filteredCases: ICase[]) => (
    <div className="overflow-x-auto">
      <table className="w-full">
        <thead>
          <tr className="bg-gray-100">
            <th className="p-2">Case Number</th>
            <th className="p-2">Title</th>
            <th className="p-2">Status</th>
            <th className="p-2">Priority</th>
            <th className="p-2">Assigned To</th>
            <th className="p-2">Due Date</th>
          </tr>
        </thead>
        <tbody>
          {filteredCases.map((case) => (
            <tr key={case.Id} className="border-b">
              <td className="p-2">{case.CaseNumber}</td>
              <td className="p-2">{case.Title}</td>
              <td className="p-2">
                <span className={`px-2 py-1 rounded ${getStatusColor(case.Status)}`}>
                  {case.Status}
                </span>
              </td>
              <td className="p-2">
                <span className={`px-2 py-1 rounded ${getPriorityColor(case.Priority)}`}>
                  {case.Priority}
                </span>
              </td>
              <td className="p-2">{case.AssignedTo.Title}</td>
              <td className="p-2">{new Date(case.DueDate).toLocaleDateString()}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );

  if (loading) return <div>Loading...</div>;
  if (error) return <Alert variant="destructive">{error}</Alert>;

  return (
    <Card>
      <CardHeader>
        <h2 className="text-2xl font-bold">Case Dashboard</h2>
      </CardHeader>
      <CardContent>
        <Tabs defaultValue="all">
          <TabsList>
            <TabsTrigger value="all">All Cases</TabsTrigger>
            <TabsTrigger value="high">High Priority</TabsTrigger>
            <TabsTrigger value="my">My Cases</TabsTrigger>
          </TabsList>
          <TabsContent value="all">
            {renderCaseTable(cases)}
          </TabsContent>
          <TabsContent value="high">
            {renderCaseTable(cases.filter(c => c.Priority === 'High'))}
          </TabsContent>
          <TabsContent value="my">
            {renderCaseTable(cases.filter(c => 
              c.AssignedTo.Email === props.context.pageContext.user.email
            ))}
          </TabsContent>
        </Tabs>
      </CardContent>
    </Card>
  );
};

export default CaseDashboard;
```

### B. Case Analytics Web Part
```typescript
import * as React from 'react';
import { useState, useEffect } from 'react';
import { LineChart, BarChart, PieChart } from 'recharts';
import { Card, CardHeader, CardContent } from '@/components/ui/card';
import _ from 'lodash';

interface ICaseAnalytics {
  context: WebPartContext;
  timeRange: 'week' | 'month' | 'quarter';
}

const CaseAnalytics: React.FC<ICaseAnalytics> = (props) => {
  const [analyticsData, setAnalyticsData] = useState({
    trendData: [],
    categoryData: [],
    priorityData: []
  });

  useEffect(() => {
    fetchAnalyticsData();
  }, [props.timeRange]);

  const fetchAnalyticsData = async () => {
    // Fetch and process data for charts
    const response = await props.context.spHttpClient.get(
      `${props.context.pageContext.web.absoluteUrl}/_api/web/lists/getbytitle('Cases')/items`,
      SPHttpClient.configurations.v1
    );
    
    const data = await response.json();
    
    // Process data for different charts
    const trendData = processTrendData(data.value);
    const categoryData = processCategoryData(data.value);
    const priorityData = processPriorityData(data.value);
    
    setAnalyticsData({ trendData, categoryData, priorityData });
  };

  return (
    <div className="grid grid-cols-2 gap-4">
      <Card>
        <CardHeader>Case Trend</CardHeader>
        <CardContent>
          <LineChart width={400} height={300} data={analyticsData.trendData}>
            {/* Chart configuration */}
          </LineChart>
        </CardContent>
      </Card>
      
      <Card>
        <CardHeader>Categories</CardHeader>
        <CardContent>
          <PieChart width={400} height={300} data={analyticsData.categoryData}>
            {/* Chart configuration */}
          </PieChart>
        </CardContent>
      </Card>
      
      <Card>
        <CardHeader>Priority Distribution</CardHeader>
        <CardContent>
          <BarChart width={400} height={300} data={analyticsData.priorityData}>
            {/* Chart configuration */}
          </BarChart>
        </CardContent>
      </Card>
    </div>
  );
};
```

## 4. Extended Troubleshooting Guide

### A. Data Access Issues

1. List Threshold Errors
```powershell
# Check list item count
$list = Get-PnPList -Identity "Cases"
if ($list.ItemCount -gt 5000) {
    # Create indexed columns
    Set-PnPField -List "Cases" -Identity "Created" -Values @{Indexed=$true}
    Set-PnPField -List "Cases" -Identity "Modified" -Values @{Indexed=$true}
    
    # Create filtered views
    Add-PnPView -List "Cases" -Title "Recent Cases" -Fields @("Title","CaseNumber","Status","Priority","AssignedTo") -Query "<OrderBy><FieldRef Name='Created' Ascending='FALSE'/></OrderBy><Where><Geq><FieldRef Name='Created'/><Value Type='DateTime'><Today OffsetDays='-30'/></Value></Geq></Where>"
}
```

2. Permission Issues
```powershell
# Diagnose permission issues
function Test-UserPermissions {
    param(
        [string]$siteUrl,
        [string]$userEmail,
        [string]$listTitle
    )
    
    Connect-PnPOnline -Url $siteUrl
    
    # Check user's site permissions
    $user = Get-PnPUser | Where-Object { $_.Email -eq $userEmail }
    $userPerms = Get-PnPUserEffectivePermissions -User $user.LoginName
    
    # Check list permissions
    $list = Get-PnPList -Identity $listTitle
    if ($list.HasUniqueRoleAssignments) {
        $listPerms = Get-PnPListPermissions -Identity $listTitle | 
            Where-Object { $_.PrincipalId -eq $user.Id }
    }
    
    return @{
        SitePermissions = $userPerms
        ListPermissions = $listPerms
        HasUniquePermissions = $list.HasUniqueRoleAssignments
    }
}
```

### B. Web Part Issues

1. Performance Troubleshooting
```typescript
// Performance monitoring wrapper
const withPerformanceTracking = (WrappedComponent: React.ComponentType<any>) => {
  return class extends React.Component {
    componentDidMount() {
      console.time('ComponentRender');
      this.logPerformanceMetrics();
    }

    componentWillUnmount() {
      console.timeEnd('ComponentRender');
    }

    logPerform