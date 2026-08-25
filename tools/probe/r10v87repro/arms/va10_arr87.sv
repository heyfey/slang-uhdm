// r10v87 arm va10 — INSTANCE ARRAYS and a generate-for home, plus an
// interface instantiated inside the loop: three elaborated instances of the
// same body, only some of them overridden.
package pa10;
  localparam int AA = 121;
  localparam int AB = 122;
endpackage

interface aifc #(parameter int AA = 1) ();
  import pa10::*;
  logic [7:0] v;
  assign v = AA[7:0] + AB[7:0];
endinterface

module aleaf #(parameter int AA = 1) (output logic [7:0] o);
  import pa10::*;
  assign o = AA[7:0] + AB[7:0];
endmodule

module top87 (output logic [7:0] o1, o2);
  logic [7:0] ao [0:2];
  aleaf #(.AA(7)) u_arr [0:2] (.o(ao));
  assign o1 = ao[0] + ao[1] + ao[2];

  logic [7:0] go [0:1];
  for (genvar gi = 0; gi < 2; gi++) begin : g_l
    aleaf #(.AA(7 + gi)) u_g (.o(go[gi]));
    aifc  #(.AA(7 + gi)) u_i ();
  end
  assign o2 = go[0] + go[1];
endmodule
