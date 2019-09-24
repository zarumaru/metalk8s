import React, { useState } from 'react';
import { connect, useSelector } from 'react-redux';
import { withRouter } from 'react-router-dom';
import styled from 'styled-components';
import { injectIntl } from 'react-intl';
import { Table, Button, Breadcrumb } from '@scality/core-ui';
import { padding } from '@scality/core-ui/dist/style/theme';

import { sortSelector } from '../services/utils';
import NoRowsRenderer from '../components/NoRowsRenderer';
import {
  BreadcrumbContainer,
  BreadcrumbLabel,
  StyledLink,
} from '../components/BreadcrumbStyle';

const PageContainer = styled.div`
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  height: 100%;
  padding: ${padding.base};
`;

const PageSubtitle = styled.h3`
  margin: ${padding.small} 0;
  display: flex;
  align-items: center;
`;

const VersionLabel = styled.label`
  padding: 0 5px;
`;

const SolutionsList = props => {
  const [sortBy, setSortBy] = useState('name');
  const [sortDirection, setSortDirection] = useState('ASC');
  const theme = useSelector(state => state.config.theme);

  const { intl, solutions } = props;
  const solutionColumns = [
    {
      label: intl.messages.name,
      dataKey: 'name',
      flexGrow: 1,
    },
    {
      label: intl.messages.versions,
      dataKey: 'versions',
      renderer: versions =>
        versions.map((version, index) => (
          <VersionLabel key={`version_${index}`}>
            {version.version}
          </VersionLabel>
        )),
      flexGrow: 1,
    },
    // {
    //   label: intl.messages.deployed_version,
    //   dataKey: 'versions',
    //   renderer: versions =>
    //     versions.map((version, index) => {
    //       return version.deployed && version.ui_url ? (
    //         <a href={version.ui_url} key={`deployed_version_${index}`}>
    //           {version.version}
    //         </a>
    //       ) : null;
    //     }),
    //   flexGrow: 1,
    // },
  ];

  const ButtonContainer = styled.span`
    margin-left: 10px;
  `;

  const stacksColumn = [
    {
      label: intl.messages.name,
      dataKey: 'name',
    },
    {
      label: 'Description',
      dataKey: 'description',
      flexGrow: 1,
    },
    {
      label: 'Solutions',
      dataKey: 'solutions',
      renderer: solutions => {
        return (
          <div>
            <span>
              {solutions.map((solution, idx) => (
                <ButtonContainer key={`solution_${idx}`}>
                  <Button
                    text={`${solution.name} ${solution.version}`}
                    size="smaller"
                  ></Button>
                </ButtonContainer>
              ))}
            </span>
            <ButtonContainer>
              <Button text="+" size="smaller" />
            </ButtonContainer>
          </div>
        );
      },
      flexGrow: 1,
    },
  ];

  const TableContainer = styled.div`
    height: 30%;
    margin: 0 0 50px 0;
  `;

  const onSort = ({ sortBy, sortDirection }) => {
    setSortBy(sortBy);
    setSortDirection(sortDirection);
  };

  const solutionsSortedList = sortSelector(solutions, sortBy, sortDirection);

  const formattedStack = props.stacks.map(stack => {
    return {
      name: stack?.metadata?.name ?? '',
      description: stack?.spec?.description ?? '',
      solutions: stack?.spec?.solutions ?? [],
    };
  });

  return (
    <PageContainer>
      <BreadcrumbContainer>
        <Breadcrumb
          activeColor={theme.brand.secondary}
          paths={[
            <BreadcrumbLabel title={intl.messages.solutions}>
              {intl.messages.solutions}
            </BreadcrumbLabel>,
          ]}
        />
      </BreadcrumbContainer>
      <TableContainer>
        <PageSubtitle>Stacks</PageSubtitle>
        <Table
          list={formattedStack}
          columns={stacksColumn}
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

      <TableContainer>
        <PageSubtitle>{intl.messages.available_solutions}</PageSubtitle>
        <Table
          list={solutionsSortedList}
          columns={solutionColumns}
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
    solutions: state.config.solutions,
    stacks: state.config.stacks,
  };
}

export default injectIntl(withRouter(connect(mapStateToProps)(SolutionsList)));
