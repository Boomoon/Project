#!/usr/bin/env python
# coding: utf-8

# In[4]:


import pandas as pd
import seaborn as sns
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
plt.style.use('ggplot')
from matplotlib.pyplot import figure

get_ipython().run_line_magic('matplotlib', 'inline')
matplotlib.rcParams['figure.figsize'] = (12,8)

df=pd.read_csv(r'/Users/boom/Desktop/Python project/movies.csv')


# In[5]:


df.head()


# In[6]:


dfOrdered=(df.isna().sum()).sort_values(ascending=False)
graph=dfOrdered.plot(kind='bar')
graph.set_yscale('log')


# In[7]:


for col in df.columns:
    pct_missing=np.mean(df[col].isnull())
    print(col,pct_missing)


# In[8]:


#df.dtypes
#df['budget']=df['budget'].astype('int64')
#df[df['budget'].isna()&df['budget'].isna()]
#df.fillna(0)
df['budget']=df['budget'].fillna(0)
df[df['budget'].isna()]


# In[9]:


# Repleace NaN with 0
df['gross']=df['gross'].fillna(0)
df[df['gross'].isna()]


# In[10]:


# Convert float to int
df['budget']=df['budget'].astype('int64')
df['gross']=df['gross'].astype('int64')


# In[11]:


# Get year from released
df[['month','date']] = df['released'].str.split('(',expand=True)
df['correctedYear']= df['month'].str[-5:]
df.drop(['month','date'], axis=1, inplace=True)
df.head()


# In[12]:


df['company'].drop_duplicates().sort_values(ascending=False)


# In[13]:


pd.set_option('display.max_rows',None)


# In[14]:


# Budget high correlation
# Company high correlation


# In[15]:


# Scatter plot budget vs gross
plt.scatter(x=df['budget'],y=df['gross'],alpha=0.5)
plt.title("Budget vs Gross Earnings")
plt.xlabel("Budget")
plt.ylabel("Gross Earnings")


# In[16]:


# Plot budget vs gross using seaborn
sns.regplot(x=df['budget'],y=df['gross'], scatter_kws={"color":"red"},line_kws={"color":"blue"})


# In[17]:


# Looking at correlation (it will work only on numerical field)
df.corr(method='pearson') #pearson, kendall, spearman


# In[18]:


correlation_matrix=df.corr(method='pearson')
sns.heatmap(correlation_matrix,annot=True)
plt.title("Correlation Matric for numberic file")
plt.xlabel("Budget")
plt.ylabel("Gross Earnings")
plt.show()


# In[19]:


df_nor=df
for colname in df_nor.columns:
    if df_nor[colname].dtype == 'object':
        df_nor[colname]= df_nor[colname].astype('category')
        df_nor[colname]=df_nor[colname].cat.codes
df_nor


# In[22]:


correlation_matrix=df_nor.corr(method='pearson')
sns.heatmap(correlation_matrix,annot=True)
plt.title("Correlation Matric for numberic file")
plt.xlabel("Budget")
plt.ylabel("Gross Earnings")
plt.show()


# In[23]:


df_nor.corr()


# In[25]:


cor_mat=df_nor.corr()
cor_pairs=cor_mat.unstack()
cor_pairs


# In[31]:


sorted_pair=cor_pairs.sort_values()
sorted_pair


# In[38]:


high_cor = sorted_pair[(sorted_pair>0.6)&(sorted_pair<0.99)]
high_cor


# In[ ]:


# budget and gross has the highest correlation followed by votes and gross correlation

