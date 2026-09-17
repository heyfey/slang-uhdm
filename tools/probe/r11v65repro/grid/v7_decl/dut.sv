// v7 - DECLARATION FORMS: a net-decl-assign, multiple declarators in one
// declaration, an implicit net, and a typedef reached through a nested module
// hierarchy.  Also a net whose typedef is declared in the COMPILATION UNIT.
typedef logic [1:0] cu_t [4];   // COMPILATION-UNIT ($unit) scope typedef
typedef logic [1:0] cv_t;
module dut (output logic [1:0] o);
  typedef logic [1:0] a_t [4];
  typedef logic [1:0] v_t;
  wire v_t nda [2] = '{2'b01, 2'b10};   // net-decl-assign + declarator dim
  a_t m1, m2;                           // TWO declarators, one declaration
  cu_t cu;                              // $unit unpacked-array typedef
  cv_t cvd [2];                         // $unit packed typedef + declarator dim
  wire v_t wsingle = 2'b11;             // control: no dim, net-decl-assign
  assign o = nda[0] | m1[0] | m2[0] | cu[0] | cvd[0] | wsingle;
endmodule
