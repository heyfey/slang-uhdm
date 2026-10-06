// § pkgQualPatConnSpan267
package pp;
  typedef struct packed {
    logic sample_pulse;
    logic [3:0] w;
  } req_t;
  parameter req_t REQ_DEFAULT = '{sample_pulse: 1'b0, w: 4'h3};
endpackage
module pm (input pp::req_t strap_i, output logic o);
  assign o = strap_i.sample_pulse;
endmodule
module top (output logic o, output logic o2);
  pm u_pm(.strap_i( pp::REQ_DEFAULT ), .o(o));
  pm u_pm2(.strap_i(pp ::  REQ_DEFAULT), .o(o2));
endmodule
