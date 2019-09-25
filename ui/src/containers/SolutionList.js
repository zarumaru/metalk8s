import React, { useState } from 'react';
import { connect, useSelector } from 'react-redux';
import { withRouter } from 'react-router-dom';
import { Formik, Form } from 'formik';
import * as yup from 'yup';
import styled from 'styled-components';
import { injectIntl } from 'react-intl';
import { Table, Button, Breadcrumb, Modal, Input } from '@scality/core-ui';
import { padding } from '@scality/core-ui/dist/style/theme';

import { sortSelector } from '../services/utils';
import Loader from '../components/Loader';
import NoRowsRenderer from '../components/NoRowsRenderer';
import {
  BreadcrumbContainer,
  BreadcrumbLabel,
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

const ModalBody = styled.div``;

const FormStyle = styled.div`
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  padding-bottom: ${padding.base};
  min-height: 220px;
  .sc-input {
    display: inline-flex;
    margin: ${padding.smaller} 0;
    justify-content: center;
    .sc-input-label {
      width: 200px;
    }
  }
`;

const SolutionsList = props => {
  const [sortBy, setSortBy] = useState('name');
  const [sortDirection, setSortDirection] = useState('ASC');
  const [isAddSolutionModalOpen, setisAddSolutionModalOpen] = useState(false);
  const [selectedStack, setSelectedStack] = useState('hhaa');
  const theme = useSelector(state => state.config.theme);

  const { intl, history, solutions } = props;
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
    margin-left: ${props => (props.marginLeft ? '10px' : '0')};
  `;

  const TableContainer = styled.div`
    height: 40%;
    margin: 0 0 50px 0;
  `;

  const StackHeader = styled.div`
    display: flex;
    justify-content: space-between;
  `;

  const ActionContainer = styled.div`
    display: flex;
    justify-content: space-between;
    margin: 10px 0;
    padding: 10px 0;
  `;

  const SelectContainer = styled.div`
    display: flex;
    flex-direction: column;
    justify-content: center;
    margin-top: 20px;
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
      renderer: (solutions, row) => {
        return (
          <div>
            <span>
              {solutions.map((solution, idx) => (
                <ButtonContainer key={`solution_${idx}`} marginLeft={idx !== 0}>
                  <Button
                    text={`${solution.name} ${solution.version}`}
                    size="smaller"
                  ></Button>
                </ButtonContainer>
              ))}
            </span>
            <ButtonContainer marginLeft={solutions.length !== 0}>
              <Button
                size="smaller"
                icon={<i className="fas fa-plus" />}
                onClick={() => {
                  setSelectedStack(row.name);
                  setisAddSolutionModalOpen(true);
                }}
              />
            </ButtonContainer>
          </div>
        );
      },
      flexGrow: 1,
    },
  ];

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

  const listOfSolutionSelect = solutionsSortedList.map(solution => ({
    label: solution.name,
    value: solution.name,
  }));

  const firstSolution =
    solutionsSortedList &&
    solutionsSortedList[0] &&
    solutionsSortedList[0].name;

  const firstVersion =
    solutionsSortedList &&
    solutionsSortedList[0] &&
    solutionsSortedList[0].versions &&
    solutionsSortedList[0].versions[0] &&
    solutionsSortedList[0].versions[0].version;

  console.log('solutions', solutions);

  const initialValues = {
    solution: { label: firstSolution, value: firstSolution },
    version: { label: firstVersion, value: firstVersion },
  };

  const validationSchema = {
    solution: yup
      .object()
      .shape({
        label: yup.string().required(),
        value: yup.string().required(),
      })
      .required(),
    version: yup
      .object()
      .shape({
        label: yup.string().required(),
        value: yup.string().required(),
      })
      .required(),
  };

  const isSolutionReady = solutionsSortedList.length > 0;

  return (
    <>
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
          <StackHeader>
            <PageSubtitle>{intl.messages.create_new_stack}</PageSubtitle>
            <Button
              text={intl.messages.create_new_stack}
              onClick={() => history.push('/solutions/create-stack')}
              icon={<i className="fas fa-plus" />}
            />
          </StackHeader>

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

      <Modal
        close={() => setisAddSolutionModalOpen(false)}
        isOpen={isAddSolutionModalOpen}
        title={intl.formatMessage(
          { id: 'add_solution_to_stack' },
          { stack: selectedStack },
        )}
      >
        {isSolutionReady ? (
          <Formik
            initialValues={initialValues}
            validationSchema={validationSchema}
            onSubmit={values => {
              const selectedSolution = solutionsSortedList.find(
                solution => solution.name === values.solution.value,
              );

              const selectedVersion = selectedSolution.versions.find(
                version => version.version === values.version.value,
              );

              const url = `${selectedVersion.ui_url}/stacks/${selectedStack}/version/${selectedVersion.version}/prepare`;

              window.open(url, '_blank');
            }}
          >
            {formikProps => {
              const { setFieldValue, values } = formikProps;

              const handleSelectChange = field => selectedObj => {
                setFieldValue(field, selectedObj ? selectedObj : '');
              };

              let listSelectedSolutionVersion = solutionsSortedList.find(
                solution => solution.name === values.solution.value,
              )?.versions;

              listSelectedSolutionVersion =
                listSelectedSolutionVersion &&
                listSelectedSolutionVersion.map(x => ({
                  label: x.version,
                  value: x.version,
                }));

              return (
                <ModalBody>
                  <Form>
                    <FormStyle>
                      <SelectContainer>
                        <Input
                          label={intl.messages.solutions}
                          clearable={false}
                          type="select"
                          options={listOfSolutionSelect}
                          placeholder={intl.messages.select_a_type}
                          noOptionsMessage={() => intl.messages.no_results}
                          name="solutions"
                          onChange={handleSelectChange('solution')}
                          value={values.solution}
                        />
                        <Input
                          id="type_input"
                          label={intl.messages.type}
                          clearable={false}
                          type="select"
                          options={listSelectedSolutionVersion}
                          placeholder={intl.messages.select_a_type}
                          noOptionsMessage={() => intl.messages.no_results}
                          name="version"
                          onChange={handleSelectChange('version')}
                          value={values.version}
                        />
                      </SelectContainer>

                      <ActionContainer>
                        <Button
                          outlined
                          text={intl.messages.cancel}
                          onClick={() => {}}
                        />
                        <Button text={'Add Solution'} type="submit" />
                      </ActionContainer>
                    </FormStyle>
                  </Form>
                </ModalBody>
              );
            }}
          </Formik>
        ) : (
          <Loader />
        )}
      </Modal>
    </>
  );
};

function mapStateToProps(state) {
  return {
    solutions: state.app.solutions.solutions,
    stacks: state.app.solutions.stacks,
  };
}

export default injectIntl(withRouter(connect(mapStateToProps)(SolutionsList)));
