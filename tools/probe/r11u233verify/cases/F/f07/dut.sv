// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — delay controls in a package task: #p2::K (ps_identifier) and #(p2::K)
package p1;
  task automatic t(output int r);
    #p2::K r = 1;
    #(p2::K) r = 2;
  endtask
  localparam int X = 1;
endpackage
package p2;
  typedef enum logic [2:0] {E0, E1, E2, E3, E4} e_t;
  localparam int K = 4;
  localparam logic [7:0] W = 8'hA5;
endpackage
module dut (output int o);
  assign o = p1::X;
endmodule
