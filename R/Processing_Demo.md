# Demo: Downloading, Processing, and Quality Check of CGM Datasets

## Goal:
To guide users through downloading the dataset from the original source, processing it, and performing a quality check.

### Steps:

1. **Load the Dataset from the Original Download Source**
   - Begin by downloading the dataset from the source specified (ensure you have access to the dataset).
   
2. **Store the Raw Dataset in the Appropriate Folder**
   - Place the raw data files in the same folder path where the processing script is located.
   - Ensure the folder structure is consistent for smooth processing.

3. **Run `processing.R` or `processing_updated.R`**
   - Execute either `processing.R` or `processing_updated.R` to process the raw data.
   - Ensure that a subfolder named `csv` exists under the folder where the script is being executed. If not, create one manually.

4. **(Optional) Run the Quality Check Script**
   - After processing the targeted datasets, run the script `filter_missing_data.R` to filter out low-quality data.
   - This script drops data based on minimal exclusion criteria (e.g., high levels of missing or sparse data).

5. **(Optional) Visual Quality Check**
   - For a visual inspection of the data, run the `plot_check_csv.R` script. This will generate visualizations of data points for each subject across datasets to help assess data quality.

6. **Processed Data Output**
   - After the above steps, the processed CSV files will be available in the `csv` folder. You can find the cleaned and quality-checked datasets ready for analysis.
