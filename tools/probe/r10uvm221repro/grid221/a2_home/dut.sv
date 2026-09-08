// r10uvm221 arm a2_home — THE ENUM-HOME MATRIX inside an UNINSTANTIATED
// interface, with the INSTANTIATED twin beside it.
//
// The producer question this arm answers: `UhdmWriter::lateBinding`
// (UhdmWriter.cpp:3294) has THREE roads to an enum-constant actual —
//   * the `::`-qualified head (:3300 onwards),
//   * the enum_var-TYPESPEC walk (:3920-3934), and
//   * the `mod->getValue(name)` MINT (:3953-3961),
// and `writeInterface` (:1626-1794) calls none of them.  Every home below is a
// different route into `getValue`, so if any one of them survived for an
// uninstantiated interface this arm would show it.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

package q221;
   typedef enum int {QE_A = 11, QE_B = 12} qe221_t;
   localparam int QLP = 99;
endpackage

typedef enum int {UU_A = 21, UU_B = 22} uu221_t;   // $unit-scope enum

class c221;
   typedef enum int {CE_A = 31, CE_B = 32} ce221_t;
   int cprop;
   function int cm221(int a_x);
      int loc;
      loc = CE_A;                                  // h07 class-scope enum, in-body
      return loc;
   endfunction
endclass

interface ifh221u;                                 // NEVER INSTANTIATED
   import q221::*;
   typedef enum int {IE_A = 41, IE_B = 42} ie221_t; // the INTERFACE's own enum
   ie221_t         imem;
   localparam int  ILP = 55;

   function int homes221(input int a_x);
      int loc;
      typedef enum int {SE_A = 51, SE_B = 52} se221_t;  // a SUBROUTINE-LOCAL enum
      se221_t sloc;
      c221    hobj;
      loc  = IE_A;                                 // h01 the interface's OWN enum
      loc  = QE_A;                                 // h02 an IMPORTED package enum
      loc  = q221::QE_B;                           // h03 a ::-QUALIFIED package enum
      loc  = UU_A;                                 // h04 a $unit-scope enum
      loc  = SE_A;                                 // h05 a SUBROUTINE-LOCAL enum
      loc  = ILP;                                  // h06 the interface's own LOCALPARAM
      imem = IE_B;                                 // h08 enum_var LHS, enum-const RHS
      sloc = SE_B;                                 // h09 local enum_var target
      loc  = QLP;                                  // h10 an imported package LOCALPARAM
      if (imem == IE_A) loc = loc + 1;             // h11 enum_var compared to its own const
      return loc;
   endfunction
endinterface

interface ifh221i;                                 // THE SAME BODY, INSTANTIATED
   import q221::*;
   typedef enum int {IE_A = 41, IE_B = 42} ie221_t;
   ie221_t         imem;
   localparam int  ILP = 55;

   function int homes221(input int a_x);
      int loc;
      typedef enum int {SE_A = 51, SE_B = 52} se221_t;
      se221_t sloc;
      c221    hobj;
      loc  = IE_A;                                 // h01
      loc  = QE_A;                                 // h02
      loc  = q221::QE_B;                           // h03
      loc  = UU_A;                                 // h04
      loc  = SE_A;                                 // h05
      loc  = ILP;                                  // h06
      imem = IE_B;                                 // h08
      sloc = SE_B;                                 // h09
      loc  = QLP;                                  // h10
      if (imem == IE_A) loc = loc + 1;             // h11
      return loc;
   endfunction
endinterface

module toph221;
   ifh221i u_ifh ();
endmodule
