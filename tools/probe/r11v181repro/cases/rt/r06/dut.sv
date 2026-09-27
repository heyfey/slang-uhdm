// § rootPathFullNameByChain181 (v11u181 break: $root in an assertion, a $display, a case item and a repeat)
module top;
  logic [3:0] v;
  int k;
  initial begin
    repeat ($root.top.k) v++;
    case (v)
      $root.top.k: v = 1;
      default: ;
    endcase
    assert ($root.top.v != 0) else $display("%d", $root.top.v);
  end
endmodule
