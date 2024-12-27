import React, { useState, useEffect } from 'react';
import Papa from 'papaparse';
import { Search } from 'lucide-react';

const SitesDashboard = () => {
  const [sites, setSites] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [sortConfig, setSortConfig] = useState({ key: 'Site name', direction: 'asc' });

  useEffect(() => {
    const loadData = async () => {
      try {
        const response = await window.fs.readFile('Sites_20241201194031240.csv', { encoding: 'utf8' });
        const result = Papa.parse(response, {
          header: true,
          dynamicTyping: true,
          skipEmptyLines: true
        });
        setSites(result.data);
      } catch (error) {
        console.error('Error loading data:', error);
      }
    };
    loadData();
  }, []);

  const formatValue = (value) => {
    if (value === null || value === undefined) return '-';
    if (typeof value === 'boolean') return value ? 'Yes' : 'No';
    if (typeof value === 'number') {
      if (value === 0) return '0';
      return value.toLocaleString();
    }
    return value;
  };

  const sortData = (data, sortConfig) => {
    if (!sortConfig.key) return data;

    return [...data].sort((a, b) => {
      const aValue = a[sortConfig.key];
      const bValue = b[sortConfig.key];

      if (aValue === null || aValue === undefined) return sortConfig.direction === 'asc' ? 1 : -1;
      if (bValue === null || bValue === undefined) return sortConfig.direction === 'asc' ? -1 : 1;

      if (aValue < bValue) return sortConfig.direction === 'asc' ? -1 : 1;
      if (aValue > bValue) return sortConfig.direction === 'asc' ? 1 : -1;
      return 0;
    });
  };

  const requestSort = (key) => {
    const direction = sortConfig.key === key && sortConfig.direction === 'asc' ? 'desc' : 'asc';
    setSortConfig({ key, direction });
  };

  const filteredSites = sites.filter(site => 
    Object.values(site).some(value => 
      String(value).toLowerCase().includes(searchTerm.toLowerCase())
    )
  );

  const sortedSites = sortData(filteredSites, sortConfig);

  const importantColumns = [
    'Site name',
    'URL',
    'Primary admin',
    'Template',
    'Date created',
    'Storage used (GB)',
    'External sharing'
  ];

  return (
    <div className="w-full p-4 space-y-4">
      <div className="flex items-center space-x-2 mb-4">
        <Search className="w-4 h-4 text-gray-500" />
        <input
          type="text"
          placeholder="Search sites..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="w-64 px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>

      <div className="overflow-x-auto rounded-lg border border-gray-200">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              {importantColumns.map((column) => (
                <th
                  key={column}
                  onClick={() => requestSort(column)}
                  className="px-4 py-3 text-left text-sm font-medium text-gray-500 cursor-pointer hover:bg-gray-100"
                >
                  <div className="flex items-center space-x-1">
                    <span>{column}</span>
                    {sortConfig.key === column && (
                      <span className="ml-1">
                        {sortConfig.direction === 'asc' ? '↑' : '↓'}
                      </span>
                    )}
                  </div>
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {sortedSites.map((site, index) => (
              <tr
                key={index}
                className="hover:bg-gray-50"
              >
                {importantColumns.map((column) => (
                  <td key={column} className="px-4 py-3 text-sm text-gray-500 whitespace-nowrap">
                    {column === 'URL' ? (
                      <a 
                        href={site[column]} 
                        target="_blank" 
                        rel="noopener noreferrer" 
                        className="text-blue-600 hover:underline"
                      >
                        {site[column]}
                      </a>
                    ) : (
                      formatValue(site[column])
                    )}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      
      <div className="text-sm text-gray-500 mt-4">
        Showing {sortedSites.length} of {sites.length} sites
      </div>
    </div>
  );
};

export default SitesDashboard;