// § methCallNameSpanAcrossLines244
module top;
  string s; int q[$]; int n;
  initial begin
    s = "abc";
    n = s .len();
    n = s.
        len();
    q .push_back(1);
    n = q. size();
    q .delete();
  end
endmodule
