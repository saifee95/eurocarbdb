/*
*   EuroCarbDB, a framework for carbohydrate bioinformatics
*
*   Copyright (c) 2006-2009, Eurocarb project, or third-party contributors as
*   indicated by the @author tags or express copyright attribution
*   statements applied by the authors.  
*
*   This copyrighted material is made available to anyone wishing to use, modify,
*   copy, or redistribute it subject to the terms and conditions of the GNU
*   Lesser General Public License, as published by the Free Software Foundation.
*   A copy of this license accompanies this distribution in the file LICENSE.txt.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
*   or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
*   for more details.
*
*   Last commit: $Rev: 1147 $ by $Author: glycoslave $ on $Date:: 2009-06-04 #$  
*/

package org.eurocarbdb.dataaccess.core;

// Generated 3/08/2006 16:48:23 by Hibernate Tools 3.1.0.beta4

import java.io.Serializable;
import org.eurocarbdb.dataaccess.BasicEurocarbObject;

/**
*   DiseaseRelations generated by hbm2java
*/
public class DiseaseRelations extends BasicEurocarbObject implements Serializable 
{

    // Fields    

     private int diseaseId;
     
     private Disease disease;
     
     private int leftIndex;
     
     private int rightIndex;


    // Constructors

    /** default constructor */
    public DiseaseRelations() 
    {
    }

    
    /** full constructor */
    public DiseaseRelations(Disease disease, int leftIndex, int rightIndex) 
    {
        this.disease = disease;
        this.leftIndex = leftIndex;
        this.rightIndex = rightIndex;
    }
    

   
    // Property accessors

    public int getDiseaseId() 
    {
        return this.diseaseId;
    }
    
    public void setDiseaseId(int diseaseId) 
    {
        this.diseaseId = diseaseId;
    }

    public Disease getDisease() 
    {
        return this.disease;
    }
    
    public void setDisease(Disease disease) 
    {
        this.disease = disease;
    }

    public int getLeftIndex() 
    {
        return this.leftIndex;
    }
    
    public void setLeftIndex(int leftIndex) 
    {
        this.leftIndex = leftIndex;
    }

    public int getRightIndex() 
    {
        return this.rightIndex;
    }
    
    public void setRightIndex(int rightIndex) 
    {
        this.rightIndex = rightIndex;
    }
   
} // end class


