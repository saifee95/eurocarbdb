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
*   Last commit: $Rev: 1210 $ by $Author: glycoslave $ on $Date:: 2009-06-12 #$  
*/
package org.eurocarbdb.dataaccess.hplc;
// Generated 29-Jan-2008 16:27:44 by Hibernate Tools 3.2.0.b9

//  eurocarb imports
import org.eurocarbdb.dataaccess.BasicEurocarbObject;
import static org.eurocarbdb.dataaccess.Eurocarb.getEntityManager;


/**
* Multipleglycoct generated by hbm2java
*/
public class Multipleglycoct  implements java.io.Serializable {


     private int id;
     private Integer glycanId;
     private Integer sequenceId;

    public Multipleglycoct() {
    }

    
    public Multipleglycoct(int id) {
        this.id = id;
    }
    public Multipleglycoct(int id, Integer glycanId, Integer sequenceId) {
       this.id = id;
       this.glycanId = glycanId;
       this.sequenceId = sequenceId;
    }
   
    public int getId() {
        return this.id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    public Integer getGlycanId() {
        return this.glycanId;
    }
    
    public void setGlycanId(Integer glycanId) {
        this.glycanId = glycanId;
    }
    public Integer getSequenceId() {
        return this.sequenceId;
    }
    
    public void setSequenceId(Integer sequenceId) {
        this.sequenceId = sequenceId;
    }

    public static Multipleglycoct lookupById( int id )
    {
        //log.debug("looking up profile by profileId");
        Object i = getEntityManager()
                  .getQuery( "org.eurocarbdb.dataaccess.hplc.Multipleglycoct.BY_ID" )
                  .setParameter("sequenceId", id )
          .setMaxResults(1)
                  .uniqueResult();

        assert i instanceof Multipleglycoct;

        return (Multipleglycoct) i;
    }



}


