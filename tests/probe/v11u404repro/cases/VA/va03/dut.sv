// § assocIdxSpanAtTokens404
class C; int x; endclass
module top;
  int a [ C ];
  string s [ string ];
  initial begin a[null] = 1; s["k"] = "v"; end
endmodule
