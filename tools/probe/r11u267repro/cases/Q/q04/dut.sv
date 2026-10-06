// § pkgQualPatConnSpan267
package pp;
  typedef struct packed {
    logic sample_pulse;
    logic [3:0] w;
  } req_t;
  parameter req_t REQ_DEFAULT = '{
    sample_pulse: 1'b0,
    w: 4'h3
  };
endpackage
module pm (input pp::req_t strap_i, output logic o);
  assign o = strap_i.sample_pulse;
endmodule
module top import pp::*; (output logic o2);
  pm u_pm2(REQ_DEFAULT, o2);
endmodule
