// t36e — the typespec of a `string'(...)` cast, with the three keyword-cast
// negative controls (`bit'`, `logic'`, `int'`) that already have arms.
// Scoreboard/SimpleUVM's first failing pair after § ...26 is uvm_printer.svh
// :1189 `s = {s, string'(knobs.separator[0]), linefeed};` — golden
// string_typespec, ours logic_typespec.
package pk1;
  string sep = "ab";

  function automatic string f_str(byte b);
    string s;
    s = {s, string'(b), "x"};
    return s;
  endfunction

  function automatic int f_ctl(logic [7:0] v);
    int i;
    i = int'(v) + logic'(v[0]) + bit'(v[1]);
    return i;
  endfunction
endpackage

module top;
  import pk1::*;
  string t;
  int    u;
  initial begin
    t = {t, string'(sep[0])};
    u = int'(sep.len()) + bit'(1'b1);
  end
endmodule
