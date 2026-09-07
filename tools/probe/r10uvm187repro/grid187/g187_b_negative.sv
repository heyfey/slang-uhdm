// r10uvm187 arm B — THE NEGATIVE FACES the law must NOT touch: a
// package-QUALIFIED reference (shares, no clone), a typedef OF a typedef
// (shares the package's own alias object), enum / struct typedefs (share),
// a written builtin type, and an untyped parameter.
package nb_pkg;
  typedef int    n_i_t;
  typedef n_i_t  n_i2_t;
  typedef enum bit [1:0] { NA, NB } n_e_t;
  typedef struct packed { bit [3:0] a; bit [3:0] b; } n_s_t;
  parameter n_i2_t N_TDTD = 5;
  parameter n_e_t  N_E    = NA;
  parameter n_s_t  N_S    = 8'h21;
  parameter int    N_RAW  = 6;
  parameter        N_UNT  = 7;
endpackage
package nq_pkg;
  parameter nb_pkg::n_i_t NQ_QUAL = 8;   // QUALIFIED: shares, no clone
  localparam nb_pkg::n_i_t NQ_QL  = 9;
endpackage
module nb_m ();
  parameter nb_pkg::n_i_t NM_QUAL = 10;
endmodule
