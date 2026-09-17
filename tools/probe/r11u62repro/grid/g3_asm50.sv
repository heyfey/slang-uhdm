// r11u50 grid g3 -- ARM (b) of the C7 head: the param_assign Rhs of a
// PACKED-STRUCT parameter whose value a member-assigning constant function
// built, read in five HOLDERS.  b3 is struct_member_cfg_width's own shape.
package r50;
  typedef struct packed { logic [31:0] XLEN; logic [31:0] TID; } cfg_t;
  function automatic cfg_t build_config();
    cfg_t c; c.XLEN = 32'd64; c.TID = 32'd3; return c;
  endfunction
  localparam cfg_t CFG = build_config();          // b1 the PACKAGE holder
endpackage

module h2 #(parameter r50::cfg_t P = r50::build_config()) (output logic o);
  assign o = P.TID[0];                             // b2 a MODULE parameter, NOT overridden
endmodule
module h3 #(parameter r50::cfg_t P = r50::build_config()) (output logic o);
  assign o = P.TID[0];                             // b3 OVERRIDDEN with the same call
endmodule
module h4 #(parameter r50::cfg_t P = r50::build_config()) (output logic o);
  assign o = P.TID[0];                             // b4 OVERRIDDEN with a literal
endmodule
module h5 (output logic o);
  localparam r50::cfg_t L = r50::CFG;              // b5 a LOCALPARAM reading the package one
  assign o = L.TID[0];
endmodule
module h6 (output logic o);
  localparam r50::cfg_t M = r50::build_config();   // b6 a MODULE localparam calling it
  assign o = M.TID[0];
endmodule

module tb52;
  logic o2, o3, o4, o5, o6;
  h2 u2 (.o(o2));
  h3 #(.P(r50::build_config())) u3 (.o(o3));
  h4 #(.P(64'h0000_0020_0000_0005)) u4 (.o(o4));
  h5 u5 (.o(o5));
  h6 u6 (.o(o6));
endmodule
