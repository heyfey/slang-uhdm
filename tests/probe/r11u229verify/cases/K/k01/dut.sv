// § strLitContOwnerEnd224 (a continued literal as a formal's default value)
module top(output string o);
  function automatic string f(string s = "ab \
cd"); return s; endfunction
  initial o = f();
endmodule
