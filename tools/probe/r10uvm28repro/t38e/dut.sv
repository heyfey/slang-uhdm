// r10uvm28 t38e — BUILT-IN method-call arguments.
//
// After the first two laws, the head of the Scoreboard/SimpleUVM package
// listing is `uvm_scope_stack::set`'s `m_stack.push_back(s)`: golden binds the
// argument to the method's io_decl, we leave it bare (269 failing listing
// elements).  § classArgBind12 opens its window for USER subroutine calls
// only, and a queue/array/string built-in takes a different emission arm.
// The cells below feed a built-in method a formal, a body local and a class
// property, at top level and inside a control body, with `$display` as the
// system-call control that must stay bare in every arm.
package pk;

  class c;
    int q[$];
    string sq[$];
    int p;

    function void go(string s, int a);
      int lb;
      sq.push_back(s);
      q.push_back(a);
      q.push_back(lb);
      q.push_back(p);
      q.delete();
      $display("%0d", a);
      $display("%0d", lb);
    endfunction

    function void nested(string s, int a);
      int lb;
      if (p == 0) begin
        sq.push_back(s);
        q.push_back(lb);
      end
      for (int k = 0; k < 2; k++)
        q.push_back(a);
    endfunction

    // out-of-body twin, which binds everywhere already
    extern function void oob(string s, int a);
  endclass

  function void c::oob(string s, int a);
    int lb;
    sq.push_back(s);
    q.push_back(lb);
    $display("%0d", a);
  endfunction

endpackage

module top;
  pk::c h;
  initial begin
    h = new();
    h.go("x", 1);
    h.nested("x", 1);
    h.oob("x", 1);
  end
endmodule
