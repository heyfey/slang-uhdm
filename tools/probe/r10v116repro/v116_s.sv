// v116 arm S -- fence controls that MUST NOT move: a user class METHOD named
// randomize is illegal, so instead a user class method named randomise plus a
// module-level task named randomize, a variable named randomize, and a
// hierarchical call through an instance.
package pkg_s;
  function automatic int randomize(int a_s, int b_s);
    randomize = a_s + b_s;
  endfunction
endpackage
module sub_s;
  int randomize_res;
  task automatic randomize_task(input int x_s);
    randomize_res = x_s;
  endtask
endmodule
module top_s;
  import pkg_s::*;
  sub_s u_s();
  int q_s;
  int randomize_var;
  initial begin
    q_s = pkg_s::randomize(1, 2);
    q_s = randomize(3, 4);
    randomize_var = q_s;
    u_s.randomize_task(5);
  end
endmodule
