// r11u106 grid M2: the typedef'd unpacked-array variable in other homes.
package mp106;
  localparam int PD = 5;
  typedef logic [7:0] pk_t [PD];
endpackage
interface m2_if #(parameter int ID = 3) ();
  typedef logic [3:0] ia_t [ID];
  ia_t iv;
endinterface
module m2_child #(parameter int CD = 2) (input logic clk, output logic [3:0] q);
  typedef logic [3:0] ca_t [CD];
  ca_t cv;
  always_ff @(posedge clk) begin cv[0] <= 1; q <= cv[CD-1]; end
endmodule
module m2 #(parameter int D = 4, parameter int W = 16) (input logic clk, output logic [7:0] q, output logic [3:0] q1, output logic [3:0] q2);
  typedef struct packed { logic [3:0] a; } st_t;
  typedef st_t sa_t [D];
  sa_t v20_named;
  mp106::pk_t v21_pkg;
  typedef logic [7:0] a22_t [0:$clog2(W)];
  a22_t v22_bareclog2;
  typedef logic [7:0] a23_t [D];
  a23_t v23_init = '{default: 8'h1};
  typedef logic [7:0] a24_t [D];
  wire a24_t n24_wire;
  typedef logic [7:0] a25_t [D-1:0];
  a25_t v25_desc;
  typedef logic [7:0] a26_t [D+1];
  if (D > 1) begin : g_on
    a26_t gv;
    typedef logic [7:0] ga_t [D*3];
    ga_t gv2;
  end
  m2_if #(.ID(6)) u_if ();
  m2_child u_c1 (.clk(clk), .q(q1));
  m2_child #(.CD(7)) u_c2 (.clk(clk), .q(q2));
  always_ff @(posedge clk) q <= v20_named[0] ^ v21_pkg[0] ^ v22_bareclog2[0] ^ v23_init[0] ^ n24_wire[0] ^ v25_desc[0] ^ g_on.gv[0] ^ g_on.gv2[0];
endmodule
