# Awesome-CGM

This is a collection of links to publicly available continuous glucose monitoring (CGM) data.

CGMs are small wearable devices that allow to measure glucose levels continuously throughout the day, with some meters taking measurements as often as every 5 min. For the head start on CGM data analyses, check out our R package [iglu](https://github.com/irinagain/iglu).

This collection follows the style of Mike Love's [awesome-multi-omics](https://github.com/mikelove/awesome-multi-omics) and Sean Davis' [awesome-single-cell](https://github.com/seandavi/awesome-single-cell) repos, although the latter are collections of methods rather than dataset links.


## Citation and contributions
The original list was assembled by Mary Martin, Elizabeth Chun, David Buchanan, Eric Wang, and Sangaman Senthil as part of their [Aggie Research Project](https://aggieresearch.tamu.edu) under the supervision of Dr. Irina Gaynanova. [Contributions are welcome](https://github.com/irinagain/Awesome-CGM/blob/master/CONTRIBUTING.md).

To cite current version 1.1.0, use 

Mary Martin, Elizabeth Chun, David Buchanan, Rucha Bhat, Shaun Cass, Eric Wang, Sangaman Senthil & Irina Gaynanova. (2021, April 27). irinagain/Awesome-CGM: List of public CGM datasets (Version v1.1.0). Zenodo. [![DOI](https://zenodo.org/badge/267687517.svg)](https://zenodo.org/badge/latestdoi/267687517)


## Datasets

Below is a list overview of all datasets with the links, the same list in a table format can be seen [here](https://github.com/irinagain/Awesome-CGM/wiki). Click the name of a data set for a link to download the CGM data, pre-processing scripts, and covariate information, as well as any additional dataset-specific use agreements.

### Type 1

* [Aleppo (2017)](https://github.com/irinagain/Awesome-CGM/wiki/Aleppo-(2017))
  * The purpose of this study was to determine whether the use of continuous glucose monitoring (CGM) without blood glucose monitoring (BGM) measurements is as safe and effective as using CGM with BGM in adults (25-40) with type 1 diabetes. The total sample size was 225 participants. The Dexcom G4 was used to continuously monitor glucose levels for a span of 6 months.
  * Found by Mary Martin. CGM Processor by David Buchanan, Elizabeth Chun. Updated R processor by Shaun Cass. Uploaded by Mary Martin, Elizabeth Chun.
  
* [Anderson (2016)](https://github.com/irinagain/Awesome-CGM/wiki/Anderson-(2016))
  * This study was designed to test a closed-loop control-to-range artificial pancreas (AP) system. There are two phases to this study. Within Phase 1, there were various stages of this study starting with 0-3 weeks of practice with CGM. This was followed by 2 weeks using the study pump together with CGM known as sensor augmented pump (SAP) therapy. This was used as a baseline and followed by 2 weeks of overnight only closed loop control (CLC) and 2 weeks of 24/7 CLC. During the CLC weeks, insulin was administered by the AP system. Phase 2 continued with only 14 patients - physician’s choice. These 14 patients used the CLC system 24/7 for five additional months.
  * Found by Elizabeth Chun. CGM Processor by David Buchanan, Elizabeth Chun. Uploaded by Elizabeth Chun, Mary Martin.
 
* [Breton (2021)](https://github.com/irinagain/Awesome-CGM/wiki/Breton-(2021))
  * The study focused on children (ages 6-13) with Type 1 diabetes using the Dexcom G6 and t:Slim X2 with Control-IQ Technology over 16 weeks. The total sample size was 101 participants.
  * Found by Charlotte Xu.  Updated R processor by Charlotte Xu. Uploaded by Charlotte Xu.

* [Buckingham (2007)](https://github.com/irinagain/Awesome-CGM/wiki/Buckingham-(2007))
  * This study was designed as a pilot study to analyze use of a CGM for children with diabetes. The subjects first established a baseline during a week blinded use, followed by at home use for 3 months.
  * Found by Eric Wang. CGM Processor by David Buchanan, Elizabeth Chun. Enhanced CGM processing by Rucha Bhat. Uploaded by Elizabeth Chun, Mary Martin.

* [Chase (2005)](https://github.com/irinagain/Awesome-CGM/wiki/Chase-(2005))
  * This study focused on the use of the GlucoWatch G2 Biographer as a tool to help in diabetes care. The 200 subjects were randomly assigned to test (CGM) or control (self-monitoring blood glucose). At the end of the study duration, A1c measurements were used to compare the two groups.
  * Found by Eric Wang. Uploaded by Elizabeth Chun, Mary Martin.

* [Dubosson (2018)](https://github.com/irinagain/Awesome-CGM/wiki/Dubosson-(2018))
  * This study focused on the use of wearable devices in a non clinical setting. There are nine type 1 diabetes patients. A large variety of data other than CGM data was collected for this study, designed for research on correlations between glucose levels and physiological measures such as ECG.
  * Found by Elizabeth Chun. CGM Processor by David Buchanan, Elizabeth Chun. Uploaded by Elizabeth Chun, Mary Martin.

* [Lynch (2022)](https://github.com/irinagain/Awesome-CGM/wiki/Lynch-(2022))
  * The study aims to evaluate the transition of Type 1 diabetes management from a hybrid closed-loop system using an insulin pump and CGM to a biotic pancreas. The Dexcom G6 CGM was used across a population group aged between 6 and 71 years over a 13-week period, with a sample size of 90 participants.
  * Found by Charlotte Xu . Updated R processor by  . Uploaded by  .

* [Marling (2019)](https://github.com/irinagain/Awesome-CGM/wiki/Marling-(2019))
  * This study has 12 type 1 diabetes patients. 
  * Found by Irina Gaynanova. CGM Processor by Elizabeth Chun. Uploaded by Elizabeth Chun.

* [O’Mally (2021)](https://github.com/irinagain/Awesome-CGM/wiki/OMalley-(2021))
  * This study examined the use of the Dexcom G6 CGM and t:Slim X2 with Control-IQ Technology among children and adults (ages 14+). The study duration was 6 months with a sample size of 168 participants.
  * Found by  . Updated R processor by  . Uploaded by  .

* [Tamborlane (2008)](https://github.com/irinagain/Awesome-CGM/wiki/Tamborlane-(2008))
  * This study was designed to test CGM as a technology to assist in diabetes care. The randomized trial was intended to determine if CGM usage had a positive effect on diabetes management. The total subjects were split into two cohorts based on A1c results, with one cohort having initial A1c measurements from 7-10% and the second cohort of those with A1c levels <7%. Within each cohort, subjects were randomly assigned to a test (CGM) or control group.
  * Found by David Buchanan. CGM Processor by David Buchanan, Elizabeth Chun. Uploaded by Elizabeth Chun, Mary Martin.

* [Tsalikian (2005)](https://github.com/irinagain/Awesome-CGM/wiki/Tsalikian-(2005)) 
  * The purpose of this study was to find out how often low blood sugar (hypoglycemia) occurs during the night after exercise in late afternoon for children aged 10 to 18 with type 1 diabetes. The total sample size was 50 participants. The OneTouch Ultra Meter was used to continuously monitor glucose levels during two seperate 24 hours periods.
  * Found by Eric Wang. CGM Processor by David Buchanan, Elizabeth Chun. Uploaded by Mary Martin, Elizabeth Chun.

* [Wadwa (2023)](https://github.com/irinagain/Awesome-CGM/wiki/Wadwa-(2023))
  * The purpose of this study was to improve glycemic outcomes in young children (ages 2-6) with Type 1 diabetes using the t:slim X2 insulin pump with Control-IQ Technology and Dexcom G6 CGM. The study spanned 13 weeks with a total sample size of 102 participants.
  * Found by Charlotte Xu. Updated R processor by  . Uploaded by  .

* [Weinstock (2016)](https://github.com/irinagain/Awesome-CGM/wiki/Weinstock-(2016))
  * The purpose of this study was to identify factors associated with severe hypoglycemia in older adults (60+) with type 1 diabetes. The total sample size was 200 participants: 100 cases, 100 control. The Dexcom SEVEN PLUS was used to continuously monitor glucose levels for a span of 2 weeks.
  * Found by Mary Martin. CGM Processor by Sangaman Senthil, Elizabeth Chun. Uploaded by Mary Martin, Elizabeth Chun.
  
### Type 2
* [Broll (2021)](https://github.com/Charlotte1031/Awesome-CGM/wiki/Broll-(2021))
   * The study involved Type 2 diabetic individuals using the Dexcom G4 CGM. Data from 5 subjects is provided as an example dataset for the development of the ‘iglu’ package (https://github.com/irinagain/iglu). 
  * Found by Irina Gaynanova. Uploaded by Charlotte Xu .
  
### Other
* [Colas (2019)](https://github.com/irinagain/Awesome-CGM/wiki/Colas-(2019))
  * This study has 208 subjects, all healthy at study start and 17 developed type 2 diabetes by study end. 
  * Found by Elizabeth Chun. CGM Processor by Elizabeth Chun. Uploaded by Elizabeth Chun.

* [Hall (2018)](https://github.com/irinagain/Awesome-CGM/wiki/Hall-(2018))
  * This study analyzes how blood glucose fluctuates in healthy individuals by using a CGM to monitor glucose. Standardized meals (breakfast only) were given to a subset of patients in order to monitor the effect of meals on the glucose readings of healthy individuals. The subjects in this study had no prior diabetes diagnosis.
  * Found by Elizabeth Chun. CGM Processor by David Buchanan, Sangaman Senthil, Elizabeth Chun. Uploaded by Elizabeth Chun, Mary Martin.
  
* [Åm (2018)](https://github.com/irinagain/Awesome-CGM/wiki/%C3%85m-(2018))
  * This study was done on an **animal** model, specifically **pigs**, in order to study sensor placement and the corresponding effects on CGM data. In order to simulate meals, glucose infusions were given to non-diabetic, anesthetized pigs through IV.
  * Found by Elizabeth Chun. Uploaded by Elizabeth Chun, Mary Martin.
  
* [Shah (2019)](https://github.com/irinagain/Awesome-CGM/wiki/Shah-(2019)) 
  * The purpose of this study was to evaluate glucose control in a mixed population (ages 6 and older) and  to establish reference sensor glucose ranges in healthy, non-diabetic individuals using the Dexcom G6 CGM. The sample size was 153 participants, with varying study duration. 
 * Found by Charlotte Xu. Updated R processor by Charlotte Xu. Uploaded by Charlotte Xu .

  
### Simulators

* [Xie (2018)](https://github.com/irinagain/Awesome-CGM/wiki/Xie-(2018))
  * This repo is a python implementation of the FDA-approved UVa/Padova Simulator for research purposes. It is "reinforcement-learning-ready", with a simulation enviroment which follows OpenAI gym and rllab APIs.
  * Found by David Buchanan.

* [Lehmann (2011)](https://github.com/irinagain/Awesome-CGM/wiki/Lehman-(2011))
  * The AIDA simulator is intended for simulating the effects on the blood glucose profile of changes in insulin and diet for a typical insulin-dependent (type 1) diabetic patient. 
  * Found by David Buchanan

