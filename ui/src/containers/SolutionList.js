import React, { useState } from 'react';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';
import styled from 'styled-components';
import { injectIntl } from 'react-intl';
import { Table } from '@scality/core-ui';
import { padding } from '@scality/core-ui/dist/style/theme';
import { sortSelector } from '../services/utils';
import NoRowsRenderer from '../components/NoRowsRenderer';

const PageContainer = styled.div`
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  height: 100%;
  padding: ${padding.base};
`;

const TableContainer = styled.div`
  flex-grow: 1;
  .status {
    display: flex;
    align-items: center;

    .deploy-icon {
      width: 12px;
      height: 12px;
    }
    .sc-button {
      margin: 0 5px;
      padding: 7px;

      .sc-button-text {
        display: flex;
        align-items: flex-start;
      }
    }
    .sc-loader {
      svg {
        width: 12px;
        height: 12px;
        fill: white;
      }
    }
  }
`;

const VersionLabel = styled.label`
  padding: 0 5px;
`;
const SolutionsList = props => {
  const [sortBy, setSortBy] = useState('name');
  const [sortDirection, setSortDirection] = useState('ASC');
  const { intl, solutions } = props;
  const columns = [
    {
      label: intl.messages.name,
      dataKey: 'name',
      flexGrow: 1
    },
    {
      label: intl.messages.versions,
      dataKey: 'versions',
      renderer: versions =>
        versions.map((v, i) => (
          <VersionLabel key={`version_${i}`}> {v.version} </VersionLabel>
        )),
      flexGrow: 1
    },
    {
      label: intl.messages.deployed_version,
      dataKey: 'versions',
      renderer: versions =>
        versions.map((v, i) => {
          return v.deployed && v.ui_url ? (
            <a href={v.ui_url} key={`deployed_version_${i}`}>
              {v.version}
            </a>
          ) : null;
        }),
      flexGrow: 1
    }
  ];

  const onSort = ({ sortBy, sortDirection }) => {
    setSortBy(sortBy);
    setSortDirection(sortDirection);
  };

  const solutionsSortedList = sortSelector(solutions, sortBy, sortDirection);

  return (
    <PageContainer>
      <TableContainer>
        <Table
          list={solutionsSortedList}
          columns={columns}
          disableHeader={false}
          headerHeight={40}
          rowHeight={40}
          sortBy={sortBy}
          sortDirection={sortDirection}
          onSort={onSort}
          onRowClick={() => {}}
          noRowsRenderer={() => (
            <NoRowsRenderer content={intl.messages.no_data_available} />
          )}
        />
      </TableContainer>
    </PageContainer>
  );
};

function mapStateToProps(state) {
  return {
    solutions: state.config.solutions
  };
}

export default injectIntl(withRouter(connect(mapStateToProps)(SolutionsList)));
