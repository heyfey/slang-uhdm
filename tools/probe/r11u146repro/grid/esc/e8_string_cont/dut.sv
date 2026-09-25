// § escIdPpColumnShift146
module top;
  function automatic string nm(); return "x"; endfunction
  function automatic string f();
    return $sformatf("<html> %s  \n\
      </head>    \n", nm());
  endfunction
  string s;
  initial s = f();
endmodule
