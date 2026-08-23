// v104 arm V8 - pastes OUTSIDE a stringification (identifier building) and
// plain (non-stringified) string literals that contain backticks, mixed with
// a real stringification in the same macro body.
`define JOIN(a,b) a``b
`define ID3(a,b,c) a``_``b``_``c
`define MIXN mm
`define MIX {`"`MIXN``-```MIXN`", "plainstr"}
`define TWOSTR $display(`"`MIXN``-```MIXN`", `"nopaste`");
module v8_top;
  wire `JOIN(sig,alpha);
  wire `ID3(p,q,r);
  string arr[2];
  string s;
  initial begin
    arr = `MIX;
    `TWOSTR
    s = "plain, no backtick";
    $display(s);
  end
endmodule
