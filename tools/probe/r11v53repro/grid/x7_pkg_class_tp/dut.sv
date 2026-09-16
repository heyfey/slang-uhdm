// v11u53 BREAK-7: a package-scope CLASS with a type parameter (Surelog's
// ClassDefinition is a DesignComponent too), plus a class-body typedef control.
package pk;
  typedef struct packed { logic [31:0] a; logic [63:0] d; logic w; } req_t; // 97
  class cc #(type CT = req_t);
    typedef CT inner_t;
    localparam int CW = $bits(CT);        // class TYPE PARAMETER
    localparam int CD = $bits(req_t);     // CONTROL
  endclass
endpackage
module dut (output logic o);
  localparam int M = $bits(pk::req_t);
  assign o = ^{M[0]};
endmodule
