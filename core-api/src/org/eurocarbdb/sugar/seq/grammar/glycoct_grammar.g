/*    glycoct_grammar.g -- a grammar for carbohydrates in GlycoCT format    */


header //  <-- this section appears at the top of the auto-generated parser
{   
package org.eurocarbdb.sugar.seq.grammar; 

import org.eurocarbdb.sugar.Anomer;
import org.eurocarbdb.sugar.SugarRepeatAnnotation;
}

/*    class GlycoctParser  *//*****************************************************
*<p>
*    This class defines an LLk parser based on ANTLR (http://antlr.org) syntax 
*   rules for parsing carbohydrate sequences in GlycoCT syntax, according 
*   to the published GlycoCT spec v3. 
*</p>
*<p>
*   This class' superclass provides the majority of 
*   the semantic action code that is called from within this grammar. This
*   is in order to keep the grammar as clear as possible and to facillitate
*   re-targeting of this grammar to other languages than Java (at time of 
*   writing ANTLR also supports C++, python, C#).
*</p>
*<p>
*   Note that source code for this grammar is auto-generated by ANTLR.
*</p>
*
*   @see GlycoctLexer
*   @see GlycoctParserAdaptor
*   @see ParserAdaptor
*   @see glycoct_grammar.g
*
*    @author mjh
*/
class GlycoctParser extends Parser("org.eurocarbdb.sugar.seq.grammar.GlycoctParserAdaptor");

//~~~  ANTLR options  ~~~
options 
{
    k=2;                        /* lookahead */
    codeGenDebug=false;         /* a debugging setting */
    analyzerDebug=false;        /* a debugging setting */
    defaultErrorHandler=false;  /* needs to be false to propagate exceptions */
}

//~~~ start class init section ~~~  
//  this section is inserted directly into the top of the generated class
//  right after the class declaration. It can contain any valid (Java) code. 
{
    /* empty */
}
//~~~ end class init section ~~~  



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ GRAMMAR ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//                                              |                              |
//          grammar-specification               |      actions for grammar     |
//            written in antlr                  |        written in java       |
//                                              |                              |
//                                              |                              |

/** Toplevel rule defining a sugar sequence.  */
sugar        
        :    res_section        /*  residues  */
            (lin_section)?      /*  linkages  */
            (rep_section)?      /*  repeats   */
            
            //TODO:     (pro_section)?      /*  heterogeneity due to uncertainty  */
            //TODO: // STA section too incompletely defined grammatically - omitted
            //TODO      sta_section         /*  heterogeneity due to statistical distribution, eg GAGs */              
            EOF
        ; 
 
 

//~~~  SECTIONS  ~~~//
        
/** Rule for a RES (residues) section. */        
res_section
        :   RES 
            (residue)+
        ;


/** Rule for a LIN (linkages) section. */        
lin_section
        :   LIN
            (linkage)+
        ;
           
        
/** Rule for a PRO (heterogeneity) section. */        
pro_section
        :   PRO
            (linkage)+
        ;
        
        
/** Rule for the REP (repeats) section. */        
rep_section
        :   REP
            repeat_section_specification
        ;

        
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 'RES' SECTION

/** A numbered residue entry in the 'RES' section. */
residue
        :   INTEGER
            residue_specification
            (SEMICOLON)?
        ;
   
   
/** 
*   Rule for a single residue, which may be either a monosaccharide, 
*   a substituent, or one of the other types specified by GlycoCT 
*   (ie: INCHI, freetext).
*/
residue_specification
        :   monosac_specification
        |   substit_specification
        |   repeat_residue_specification
        //|   inchi_specification // TODO later
        ;

/** 
*   Rule that tests whether a residue is a monosaccharide. 
*   "Monosaccharide-ness" is implied by matching lexer rule 
*   MONOSAC_DECLARATION.
*/
monosac_specification
        :
            MONOSAC_DECLARATION    
            monosaccharide
        ;

/** 
*   Rule that tests whether a residue is a substituent. 
*   "Substituent-ness" is implied by matching lexer rule 
*   SUBSTIT_DECLARATION.
*/
substit_specification
        :
            SUBSTIT_DECLARATION   
            substituent_name
        ;

/**
*   Rule that tests whether a residue is a reference to a repeat sub-structure. 
*/
repeat_residue_specification
        :
            REPEAT_DECLARATION        
            IDENTIFIER          // seems to always be the letter 'r'
            i:INTEGER           // index of the repeat substructure referenced
                                                {   addRepeatResidue( i );  }
        ;
                                                
/** 
*   Rule for a monosaccharide, in GlycoCT format, consisting of a 
*   monosaccharide name, its superclass, ring closure positions, 
*   and a list of modifications at each terminus, if any. 
*/
monosaccharide                                  {   ResidueToken n;  }
        :   // note: name includes anomer  
            n=monosaccharide_name               {   addResidue( n );  }
            HYPHEN
            c:MONOSAC_SUPERCLASS                {   setSuperclass( c );  }              
            HYPHEN
            monosac_ring_closure              
            (monosac_substituents_or_modifications)*
        ;


/** 
*   Rule for a monosaccharide name. A monosaccharide name in GlycoCT
*   is basically its stem-type, that is, the name/type given to the 
*   basic monosaccharide sans mods, eg: glc. Note that there may be 
*   multiple stem-types given, separated by hyphens.
*
*   Note also that for the purposes of this rule, anomeric config is 
*   considered part of the monosaccharide name.
*/
monosaccharide_name returns [ResidueToken m = null]
        :   n:IDENTIFIER                    
            ( 
                HYPHEN 
                x:IDENTIFIER                    {   n.setText( n.getText() + "-" + x.getText() );  } 
            )*                                  {   m = createMonosaccharideToken( n );  }                                      
        ; 
        
/** 
*   Rule for a substituent name (ie: non-monosaccharide). 
*   A substituent name may be any hyphen-separated list of identifiers.
*/
substituent_name
        :   n:IDENTIFIER                        
            (
                HYPHEN 
                x:IDENTIFIER                    {   n.setText( n.getText() + "-" + x.getText() );  }
            )*                                  {   addResidue( createSubstituentToken( n ) );  }
        ;
    

/**
*   Rule for GlycoCT monosaccharide ring closure syntax, of form 
*   "[terminus_position]-[terminus_position]".
*/
monosac_ring_closure                            {   Token t1 = null, t2 = null;  }
        :                                       
            t1=terminus_position                   
            COLON
            t2=terminus_position                {   setRingClosure( t1, t2 );  }           
        ;

        
/**
*   Rule defining a valid terminus position, which may be
*   either a positive integer, or the unknown symbol ('x').
*/
terminus_position returns [Token t]
        :   i:INTEGER                           {  t = i;  }
        |   u:HYPHEN INTEGER                    {  t = u; t.setText("-1");  }
        |   q:UNKNOWN_TERMINUS                  {  t = q;  } 
        ;

/**
*   Rule for a monosaccharide modification list, which may be 
*   a pipe-symbol ('|') delimited list of monosaccharide 
*   modifications. The general form of a monosac modification is
*   "[terminus_position]:[identifier]". Modifications that affect
*   2 terminii (such as double or triple bonds) are also matched
*   by this rule.
*/
monosac_substituents_or_modifications
        :   
            PIPE
            t1:INTEGER 
            ( COMMA t2:INTEGER )? // syntax for alkenes is '|2,3:en' 
            COLON
            n:IDENTIFIER                        {   addSubstituentOrModification( n, t1, t2 );  }
        ;
    
/*
monosac_modification
        :   //IDENTIFIER
        (   "d"         //  deoxygenation  
        |   "keto"      //  a carbonyl group 
        |   "en"        //  double-bond       
        |   "enx"       //  double-bond?   
        |   "a"         //  acidic group    
        |   "aldi"      //  reduced C1 carbonyl
        |   "sp2"       //  outgoing linkage with double bond 
        |   "geminal"   //  2 OH at one backbone carbon 
        )
        ;
*/


/*
monosac_type_identifier
        :   //t:LETTER                            {  check validity here   }
        (   "b"     //  a base type  
        |   "s"     //  a substituent 
        |   "n"     //  other chemically defined entity (freetext) 
        |   "i"     //  INCHI-encoded non-basetype, non-substituent 
        |   "r"     //  repeating unit 

//  ERROR in the specification: 's' is duplicated
//        |   "s"     //  statistical unit
        )
        ;
*/


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 'LIN' SECTION

/** Rule matching a single linkage declaration. */
linkage                                         {  Token lnrt, lrt;  }                                      
        :
        //  possibly an 'R' prefix indicates a linkage to a repeat, declared in a REP section
        //  note: the presence of the 'R' isn't listed in the glyco-ct manual...
        ("R")? 
        
        //  linkage numbering 
        i:INTEGER
        COLON
        
        //  non-reducing residue id + type
        rti:INTEGER
        rtt:IDENTIFIER 

        //  then the actual linkage             
        LPARENTHESIS
        lrt=terminus_position
        (HYPHEN | PLUS)
        lnrt=terminus_position
        RPARENTHESIS
        
        //  then the reducing residue id + type
        nrti:INTEGER
        nrtt:IDENTIFIER    

        //  end of linkage
        (SEMICOLON)?                            {   addLinkage( i, rti, rtt, lrt, lnrt, nrti, nrtt );  }
        ;

/*
linkage_type_identifier returns [Token type]
        :   //t:LETTER                            {  // check validity here // type = t; }
        (   "o"     //  loss of H from OH 
        |   "h"     //  loss of H
        |   "d"     //  loss of OH 
        |   "n"     //  linkage to non-monosac/repeat
        |   "r"     //  prochiral H-atom removed, resulting in R-configuration 
        |   "s"     //  prochiral H-atom removed, resulting in S-configuration 
        )                                       {   type = LT(1);  }
        ;    
*/

/*
anomer //returns [Anomer a]            
        //:   t:LETTER                            {  a = checkAnomer( t );  }
        :   "a"       //  alpha       
        |   "b"       //  beta        
        |   "o"       //  open-chain  
        |   "x"       //  unknown             
        ;
*/

/*
stereo
        :
        (   "d"       //  dextro  
        |   "l"       //  levo    
        |   "x"       //  unknown 
        )
        ;
*/


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 'REP' SECTION

/**
*   This is the rule for a repeat ('REP') section, which starts immediately
*   after the text 'REP'.
*/
repeat_section_specification                    {   Token t1, t2, lower, upper;  }
    :
        //  the 'REP' section identifier is repeated twice; this is the second one
        REP
        
        //  repeat identifier
        i:INTEGER
        COLON
        
        //  non-reducing residue id + type
        r1:INTEGER
        rtt:IDENTIFIER 

        //  then the actual linkage             
        LPARENTHESIS
        t1=terminus_position
        (HYPHEN | PLUS)
        t2=terminus_position
        RPARENTHESIS
        
        //  then the reducing residue id + type
        r2:INTEGER
        nrtt:IDENTIFIER                         

        //  start of repeat range section
        //  range values have the same syntactic form as 
        //  terminii positions, so reusing 'terminus_position' rule.
        EQUALS                            
        lower=terminus_position                
        HYPHEN
        upper=terminus_position                 {   setRepeatRange( i, lower, upper );  }
        (SEMICOLON)?                            
        
        //  then the repeat sugar
                                                {   repeatStarts( i );  }
        res_section        
        (lin_section)?     
                                                {   
                                                    RepeatResidueToken r = getRepeat( i );
                                                    r.setRootResidueToken( getResidueToken( r2 ) );
                                                    r.setLeafResidueToken( getResidueToken( r1 ) );
                                                    r.setLinkageBetweenRepeats( createLinkageToken( null, t1, t2 ) );  

                                                    repeatEnds( i );  
                                                }
    ;
    
    
    
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  LEXER  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
/**
*
*   This class implements a lexer/scanner for carbohydrate
*   sequences in Glycoct syntax. This class was auto-generated from
*   the ANTLR lexer grammar in glycoct_grammar.g.
*
*   @see GlycoctParser
*   @see glycoct_grammar.g
*
*   @author mjh [matt@ebi.ac.uk]
*/
class GlycoctLexer extends Lexer;

options 
{
    k=3;        /*  lookahead  */
}

//~~~~~~~~~~~~~~~~~~~~  token separators & delimiters  ~~~~~~~~~~~~~~~~~~~~~~//
    
/** A literal colon ':' */
COLON
        options { paraphrase="a colon separator ':'"; }
        :   ':'
        ;
     
/** A literal comma ',' */
COMMA                
        options { paraphrase="a comma ','"; }
        :   ','
        ;

/** A literal hyphen '-' */
HYPHEN            
        options { paraphrase="a hyphen '-'"; }
        :   '-' 
        ;
        
PLUS
        options { paraphrase="a linkage terminii delimiter '+'"; }
        :   '+'
        ;
        
EQUALS
        options { paraphrase="a repeat range delimiter '='"; }
        :   '='
        ;
        
/** A literal pipe symbol '|' */
PIPE                
        options { paraphrase="a residue substitution delimiter '|'"; }
        :     '|'
        ;

/** A literal semicolon ';' */
SEMICOLON
        options { paraphrase="a residue/linkage token separator ';'"; }
        :   ';'
        ;
        
/** A literal left parenthesis '(' */
LPARENTHESIS
        options { paraphrase="a linkage start delimiter '('"; }
        :   '('
        ;
        
/** A literal right parenthesis ')' */
RPARENTHESIS
        options { paraphrase="a linkage end delimiter ')'"; }
        :   ')'
        ;
        
/** A literal '?', indicating an unknown terminal position. */
UNKNOWN_TERMINUS
        options { paraphrase="an unknown terminal position '?'"; }
        :   '?'     
        // |   HYPHEN '1'
        //|   'x'
        ;
        
//~~~~~~~~~~~~~~~~~~~~~~~~~~~ identifiers ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//


/** A literal string "b:", which declares a following monosaccharide section. */
MONOSAC_DECLARATION
        options { paraphrase="a basetype declaration 'b:'"; }
        :   "b:"
        ;

/** A literal string "s:", which declares a following substituent section. */
SUBSTIT_DECLARATION
        options { paraphrase="a substituent declaration 's:'"; }
        :   "s:"
        ;

/** A literal string "i:", which declares a section of INCHI code. */
INCHI_DECLARATION
        options { paraphrase="an inchi section declaration 'i:'"; }
        :   "i:"
        ;

/** A literal string "r:", which declares a repeat sub-structure section. */
REPEAT_DECLARATION
        options { paraphrase="a repeat structure declaration 'r:'"; }
        :   "r:"
        ;

/*  
ANOMER 
        :   'a'       //  alpha       
        |   'b'       //  beta        
        |   'o'       //  open-chain  
        |   'x'       //  unknown             
        ;
*/

/*
LINKAGE_TYPE_IDENTIFIER 
        :   
        (   'o'     //  loss of H from OH 
        |   'h'     //  loss of H
        |   'd'     //  loss of OH 
        |   'n'     //  linkage to non-monosac/repeat
        |   'r'     //  prochiral H-atom removed, resulting in R-configuration 
        |   's'     //  prochiral H-atom removed, resulting in S-configuration 
        )                                      
        ;    
*/

/*
LINKAGE_TERMINUS_DECLARATION
        :   INTEGER  LINKAGE_TYPE_IDENTIFIER
        ;
*/
 
/* mjh: these are handled in code
MONOSAC_MODIFICATION
        :  
        (   "d"         //  deoxygenation  
        |   "keto"      //  a carbonyl group 
        |   "en"        //  double-bond       
        |   "enx"       //  double-bond?   
        |   "a"         //  acidic group    
        |   "aldi"      //  reduced C1 carbonyl
        |   "sp2"       //  outgoing linkage with double bond 
        |   "geminal"   //  2 OH at one backbone carbon 
        )
        ;
*/


/** Rule for a (positive) integer, or zero. */
INTEGER
        options { paraphrase="a positive integer or zero"; }
        :   ('1'..'9')  ('0'..'9')*  
        |   '0'
        ;
        
/** Rule for an identifier, which may be any alphabetic string. */
IDENTIFIER                    
        options { paraphrase="an alphabetic identifier"; }
        :   ('a'..'z')+                         //{   if ($getText == "x") { $setType(UNKNOWN_TERMINUS); }  }
        ;
        
/*
protected UNKNOWN_TERMINUS
        options { paraphrase="an unknown terminus position"; }
        :   'x'
        ;
*/

//~~~~~~~~~~~~~~~~~~~~~~~  section type identifiers  ~~~~~~~~~~~~~~~~~~~~~~~~//

/** Rule for a literal string "RES", identifying a RES section. */
RES
        options { paraphrase="a RES (residue) section start identifier"; }
        :   "RES"
        ;
        
/** Rule for a literal string "LIN", identifying a LIN section. */
LIN     
        options { paraphrase="a LIN (linkage) section start identifier"; }
        :   "LIN" 
        ;
        
/** Rule for a literal string "PRO", identifying a PRO section. */
PRO     
        options { paraphrase="a PRO (heterogeneity due to uncertainty) section start identifier"; }
        :   "PRO"
        ;
        
/** Rule for a literal string "REP", identifying a REP section. */
REP     
        options { paraphrase="a REP (repeat) section start identifier"; }
        :   "REP"
        ;
        
/** Rule for a literal string "STA", identifying a STA section. */
STA 
        options { paraphrase="a STA (heterogeneity due to a statistical distribution) section start identifier"; }
        :   "STA"
        ;
        
/** Rule for a literal string "ISO", identifying a ISO section. */
ISO
        options { paraphrase="an ISO (isotope) section start identifier"; }
        :   "ISO"
        ;
        
/** Rule for a literal string "AGL", identifying a AGL section. */
AGL
        options { paraphrase="an AGL (aglycon) section start identifier"; }
        :   "AGL"
        ;
        
/** Rule for ring size/configuration, eg: hex (for hexose), hept (for heptose). */
MONOSAC_SUPERCLASS
        options { paraphrase="a superclass descriptor"; }
        :               //  roughly ordered by commonness/likelihood
        (   "HEX"       //  hexose (6)
        |   "PEN"       //  pentose (5)
        |   "NON"       //  nonulose (9)
        |   "OCT"       //  octose (8)
        |   "HEPT"      //  heptose (7)
        |   "TET"       //  tetrose (4)
        |   "TRI"       //  triose (3)
        )
        ; 
        
/** 
*   The "whitespace" rule, comprising space, tab, and return. 
*   These tokens are disregarded when parsing. 
*/
WS  
        : 
        (   ' '
        |   '\t' 
        |   (( '\r' '\n' ) | '\n')              {   newline();  }
        )                                       {   $setType( Token.SKIP );  }
        ;
          