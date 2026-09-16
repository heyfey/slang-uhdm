// ROAD A cell set: SAME argument ($bits of a type parameter) in five HOLDERS.
package pk;
  typedef struct packed { logic [31:0] a; logic [63:0] d; logic w; } req_t; // 97
endpackage
module dut #(
    parameter type TP = pk::req_t,
    parameter int  PW = $bits(TP)            // holder 1: parameter-port-list Rhs
) (
    output logic [PW-1:0] o,
    output logic [$bits(TP)-1:0] q           // holder 2: port range bound
);
  localparam int LW = $bits(TP);             // holder 3: body localparam Rhs
  logic [$bits(TP)-1:0] n;                   // holder 4: net range bound
  function automatic int fw();
    return $bits(TP);                        // holder 5: function body return
  endfunction
  localparam int FW = fw();
  assign o = {PW{1'b0}} | {{(PW-32){1'b0}}, LW};
  assign q = n | {{($bits(TP)-32){1'b0}}, FW};
endmodule
