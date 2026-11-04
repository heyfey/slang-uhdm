// § tfArgClassSpecNameSpan231 — s02 with CRLF line ends
package p;
  virtual class proxy #(type S=int);
    pure virtual function void get(S s);
  endclass
  class adapter;
    virtual function void accept(proxy#(int) px, proxy#(logic) py);
    endfunction
  endclass
endpackage
module top;
endmodule
