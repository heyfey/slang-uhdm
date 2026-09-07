// r10v195 arm E — the NON-PACKAGE importers.  A module, a program and an
// interface that wildcard-import the same package: Surelog pushes the HOME
// task_func itself (`sfuncs->push_back(func)`, CompileHelper.cpp:326), so
// there is NO clone and nothing this law owns may move.  MEASUREMENT ONLY.
package quay195v;
  class Tern195v;
    extern task perch195v(string p195v = "");
  endclass
  task Tern195v::perch195v(string p195v = "");
    process q_p195v;
    string  q_s195v;
    q_s195v = "u";
  endtask
  function void jetty195v();
    process j_p195v;
    string  j_s195v;
    j_s195v = "v";
  endfunction
endpackage
module harbour195v;
  import quay195v::*;
  initial begin
    process h_p195v;
    string  h_s195v;
    h_s195v = "w";
  end
endmodule
program pier195v;
  import quay195v::*;
  initial begin
    process p_p195v;
    string  p_s195v;
    p_s195v = "x";
  end
endprogram
interface slip195v;
  import quay195v::*;
  initial begin
    process s_p195v;
    string  s_s195v;
    s_s195v = "y";
  end
endinterface
