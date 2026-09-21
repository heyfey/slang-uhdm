// v11u77 vb -- LAW B face: the UNPACKED wrapper's untested spellings.
// makeHoistHolder77 reads range.width() of the OUTER dim only and builds its
// ranges from the DECLARATOR's own dimensions, so a typedef'd unpacked array
// (no declarator dims) and a 2-D one are both asked here, along with the
// int-member-struct element (ArrayVar, not ArrayNet) and the size-style dim.
package pu;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } sl_t;
  typedef struct packed { int x; logic [7:0] y; }         si_t;
  typedef logic [7:0] arr_t [0:1];
  logic [7:0] u_plain [0:1];   // the measured control
  si_t        u_si    [0:1];   // struct-with-int element  -> ArrayVar?
  wire si_t   u_nsi   [0:1];   // NET-declared, same element
  logic [7:0] u_2d    [0:1][0:2];  // TWO unpacked dims
  arr_t       u_td;            // typedef'd unpacked array: NO declarator dim
  logic [7:0] u_size  [2];     // size-style dim
  sl_t        u_sl    [0:1];   // the measured control (ArrayNet)
endpackage

module dut (output logic [31:0] o);
  import pu::*;
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] u_plain; assign u_plain = 32'd1;
    logic [31:0] u_si;    assign u_si    = 32'd2;
    logic [31:0] u_nsi;   assign u_nsi   = 32'd3;
    logic [31:0] u_2d;    assign u_2d    = 32'd4;
    logic [31:0] u_td;    assign u_td    = 32'd5;
    logic [31:0] u_size;  assign u_size  = 32'd6;
    logic [31:0] u_sl;    assign u_sl    = 32'd7;
  end
  assign o = gv[0].u_plain ^ gv[0].u_si ^ gv[0].u_nsi ^ gv[0].u_2d
           ^ gv[0].u_td ^ gv[0].u_size ^ gv[0].u_sl;
endmodule
