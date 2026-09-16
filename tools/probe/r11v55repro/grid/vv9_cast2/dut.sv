// r11v55 — WHERE GOLDEN DECLINES AND WE MIGHT NOT.  vv1c_cast showed golden
// keeping the shared def object when the package localparam is written
// `cfg_t'('{…})`, while the law substitutes a constant — but our binary
// REJECTS that source (rc=4), so the cell is unmeasurable there.  These are
// cast placements our binary accepts: a cast at the INSTANCE override and a
// cast at the MODULE parameter default, over a plainly written package
// localparam.
package p;
  typedef struct packed { int unsigned n; logic [15:0] h; } cfg_t;
  localparam cfg_t NAMED = '{n: 12, h: 16'h00CD};
  localparam cfg_t OTHER = '{n: 31, h: 16'h00EF};
endpackage
module leaf #(parameter p::cfg_t C = p::NAMED)
            (output logic [31:0] o_n, output logic [31:0] o_h);
  assign o_n = C.n;
  assign o_h = C.h;
endmodule
module dut (output logic [31:0] a_n, output logic [31:0] a_h,
            output logic [31:0] b_n, output logic [31:0] b_h);
  leaf                              u_p (.o_n(a_n), .o_h(a_h));  // control
  leaf #(.C(p::cfg_t'(p::OTHER)))   u_c (.o_n(b_n), .o_h(b_h));  // cast at the override
endmodule
