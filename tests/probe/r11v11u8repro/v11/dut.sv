// v11: an EMPTY ACTUAL ARGUMENT at the FRONT of a stringification, with body
// whitespace on BOTH sides of it, and NO line continuation anywhere.
// slang parks the marker's whitespace on the empty argument and prepends it
// to the next token, so our value carries MORE leading whitespace than the
// body writes right after the marker.
`define AB(__a,__b) `"  __a  __b`"
module top;
  initial begin
    $display("[%0s]", `AB(,yy));
    $display("[%0s]", `AB(xx,yy));
  end
endmodule
