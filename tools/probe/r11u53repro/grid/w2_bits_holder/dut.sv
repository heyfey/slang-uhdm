// r11u53 ROAD A holder set — is the HOLDER a gate?  $bits(TP) of one type
// parameter in the THREE holders that reach a JUDGED view (V5's correction to
// a2_bits_holder: a port range bound and a net range bound put the
// sys_func_call only in `weaklyReferenced`, on both sides, so they are not
// judged cells and are deliberately left out of this arm).
//   H1 parameter-port-list Rhs      H2 module-body localparam Rhs
//   H3 function-body `return`
package pk;
  typedef struct packed { logic [31:0] a; logic [63:0] d; logic w; } req_t; // 97
endpackage
module dut #(
    parameter type TP = pk::req_t,
    parameter int  H1 = $bits(TP)            // holder 1: parameter-port-list
) (
    output logic o
);
  localparam int H2 = $bits(TP);             // holder 2: body localparam
  function automatic int f();
    return $bits(TP);                        // holder 3: function-body return
  endfunction
  localparam int H3 = f();
  assign o = ^{H1[0], H2[0], H3[0]};
endmodule
