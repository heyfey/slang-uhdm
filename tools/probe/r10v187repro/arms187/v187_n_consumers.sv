// v187 arm N -- the deferred parameter CONSUMED by everything in its own
// package: a later typedef's bound, an enum base width, a struct member width,
// a net/var width, a function return width, a class parameter default, and an
// unpacked array size.
package pn2187;
  typedef int  q_i_t;
  typedef byte q_by_t;
  parameter q_i_t  Q_W = 8;
  parameter q_by_t Q_B = 4;
  typedef logic [Q_W-1:0] q_v_t;
  typedef enum bit [Q_B-1:0] { QE0, QE1 } q_e_t;
  typedef struct packed { logic [Q_W-1:0] a; logic [Q_B-1:0] b; } q_s_t;
  parameter q_v_t Q_V = 0;
  parameter q_e_t Q_E = QE0;
  parameter q_s_t Q_S = 0;
  function automatic logic [Q_W-1:0] qf(input logic [Q_B-1:0] x);
    return x;
  endfunction
  class QC187 #(parameter q_i_t QW = Q_W);
    localparam q_i_t QL = QW;
  endclass
  typedef q_i_t q_arr_t [Q_B];
endpackage
module mn2187 ();
  import pn2187::*;
  q_v_t sig;
  logic [Q_W-1:0] w;
  localparam int MN2 = Q_W + Q_B;
  QC187#(9) qc;
endmodule
