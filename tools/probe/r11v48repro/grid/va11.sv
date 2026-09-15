// va11 — a STRING body local, uvm_is_match's exact shape, but with the call in
// a WHILE loop as well as in the return expression.
package va11p;
  function automatic string g2re(string e); return e; endfunction
  function automatic int rem(string re, string str); return re == str; endfunction
  function automatic bit ismatch(string ex, string str);
    string s;
    int i = 0;
    while (i < 2) begin
      s = g2re(ex);
      i = i + 1;
    end
    return (rem(s, str) == 0);
  endfunction
endpackage
module va11 (input logic c, output logic o);
  assign o = c;
endmodule
