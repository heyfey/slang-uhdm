// § importNetTsToInitEnd183 (explicit import, multi-line initializer)
package p;
  string banner = {"abc",
                   "def"};
endpackage
module top;
  import p::banner;
  string s;
  initial s = banner;
endmodule
