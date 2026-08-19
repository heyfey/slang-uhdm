// r10v100: scoped/member/select values and delayed statement nesting.
package v100p4;
  parameter time P = 2;
endpackage
module v100_b4;
  int x, idx;
  time arr [0:1];
  initial begin
    arr[0] = 2; arr[1] = 3; idx = 0;
    #(v100p4::P) x = 1;
    #(arr[idx]) x = 2;
    #({1'b0, v100p4::P}) x = 3;
    fork : named_fork
      #(arr[0]) begin : delayed_block
        x = 4;
      end
    join_none
    while (x < 5) begin
      #(arr[idx]) x++;
    end
  end
endmodule
