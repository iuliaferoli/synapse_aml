# Data Engineer empowered with AI tools: running no-code autoML models from Synapse
## Integrating Synapse and Azure Machine Learning to create and end-to-end data science solution targeted at data engineers.

![architecture](https://github.com/iuliaferoli/synapse_aml/blob/main/img/automlarch.JPG)

[![Video Explanation](https://img.youtube.com/vi/gro6uhBjaAs/0.jpg)](https://www.youtube.com/watch?v=gro6uhBjaAs "Video Explanation")


This is the technical breakdown for the first of three scenarios for AML & Synapse integration as described in this article, exploring the different ways the two products can be used together for an end-to-end story.

The other two scenarios are: The Unicorn: creating a spark optimized custom model and The citizen data scientist / engineer: Same results with no/low code?

**For this scenario our user is familiar with the enterprise data warehouse solution, fluent in either SQL or spark (or both) and therefore will complete their work from the Synapse workspace.**

**This process enables them to create and leverage a machine learning model without writing any code or even opening Azure Machine Learning.**

After ingesting, preparing, and storing the data they want to use for analysis on the spark pool, they can now (via an GUI Wizard in the Synapse Workspace) trigger an automated machine learning task to run on their data and create a model by only specifying the target column and type of task (i.e. regression).
The model can then be deployed on the SQL pool and queries can be made against it to generate predictions for new data.

### Part 1 Generate AutoML run on Spark data

1. [Create](https://docs.microsoft.com/en-us/azure/synapse-analytics/get-started) (or use existing) Synapse instance on Azure and provision both a SQL pool and a Spark cluster.        * This also creates an ADLS gen2 account associated with Synapse
2. [Create](https://docs.microsoft.com/en-us/azure/machine-learning/how-to-manage-workspace?tabs=azure-portal) (or use existing) Azure Machine Learning instance on Azure.
3. [Create a Linked Service](https://docs.microsoft.com/en-us/azure/synapse-analytics/machine-learning/quickstart-integrate-azure-machine-learning) to this AML instance from the Manage tab in the Synapse Workspace. 
    * This will also require creating/using a service principal that is a contributor to the AML workspace and who's app ID and secret will be used in the Synapse linked service.)
4. Get your training and testing data ready. You can download [this notebook](https://github.com/iuliaferoli/synapse_aml/blob/main/Create%20Spark%20Table%20with%20NYC%20Taxi%20Data%20(with%20split%20data).ipynb) and import & run it on your Spark cluster to generate the data sets. The training data will be loaded onto your spark cluster, and the test data csv will be saved directly on your data lake storage from where you can import it into SQL in part 2.
5. Open the Data Tab in the Synapse Workspace and get to your table on the Spark Cluster (nyc_taxi_train). From Actions select Enrich with new Model and start up the Wizard for triggering an automated ML run.
<img src="https://github.com/iuliaferoli/synapse_aml/blob/main/img/enrich.JPG" width="650">

6. You will see and select the AML Workspace you provisioned and Linked to Synapse in here. Go through this wizard changing the following parameter: `target column: fareAmount`
`model type: Regression`
`ONNX model compatibility: Enabled (as this will allow deploying the model on the SQL pool)` 
7. Finish the Wizard and create the autoML run.

### Part 2 Use autoML model to get predictions on test data

1. Once the model has done training you can now use it to make predictions on the test data you generated at the previous step 4 from Part 1
2. You will find the test data in your ADLS gen2 account that you can either explore from the Azure resource group or as a Linked data source in the Synapse workspace like in the picture. Navigate to the test data you generated with the notebook and copy the URL path to it from the properties tab.
<img src="https://github.com/iuliaferoli/synapse_aml/blob/main/img/data.JPG" width="650">

3. Run [this SQL script](https://github.com/iuliaferoli/synapse_aml/blob/main/Create%20Table%20on%20SQL%20pool.sql) to create a table on your SQL pool for the test data
4. Now it's time to get the generated model from the autoML run and use it for predictions on this data. Navigate to the new SQL table under the data tab and from Actions select Enrich with existing model
<img src="https://github.com/iuliaferoli/synapse_aml/blob/main/img/sql.JPG" width="650">

5. The same AML-link Wizard will appear again and you can select your workspace and the Regression model you just created. You will then see a column mapping between the training and test data format (which should automatically match 1-to-1), and can see the model_output column, which in our case will be the fareAmount.
6. Then Synapse will generate a stored procedure containing the SQL code needed to deploy your model into a table on the SQL pool. Fill in the required names.
7. And there we have it, the SQL code generated calls PREDICT to determine the fareAmount for your test dataset which you will see as a result of the run at the bottom.

We have successfully created a machine learning model and stored it on our SQL pool from where it can be used on new data for which we want new predictions.



### Additional references
> The following two tutorials are the basis of this solution however they are separate examples that do not work together, they use the same dataset but showcase two different types of models (autoML regression, and custom-code classification in a Notebooks) and therefore are not compatible with each other, but do provide additional details for the process.


> [Tutorial: Train a model by using automated machine learning - Azure Synapse Analytics | Microsoft Docs](https://docs.microsoft.com/en-us/azure/synapse-analytics/machine-learning/tutorial-automl)


> [Tutorial: Machine learning model scoring wizard for dedicated SQL pools - Azure Synapse Analytics | Microsoft Docs](https://docs.microsoft.com/en-us/azure/synapse-analytics/machine-learning/tutorial-sql-pool-model-scoring-wizard)
