// r10uvm214 grid arm A — THE LAW.  A package with OUT-OF-BODY class methods
// whose bodies reference the package's OWN parameters, one reference per
// REFERENT KIND (what the parameter's own def-view param_assign Rhs is) and
// per READ POSITION.  The home package's DEF listing carries a clone of every
// out-of-body method; the question is what each reference in THAT listing is
// bound to, against the same reference in the ELABORATED listing.
//
// The head's own shape is `pb214` (a parameter whose initialiser is a bare
// reference to another parameter, uvm-1.2 `UVM_SETINT = UVM_SET`) read as a
// CALL ARGUMENT (uvm_object.svh:933 `__m_uvm_field_automation(null, UVM_SETINT,
// field_name)`).
package p214;

  parameter int pa214 = 5;          // referent kind: constant (literal)
  parameter pb214 = pa214;          // referent kind: ref_obj (bare param ref)
  parameter pc214 = pa214 + 1;      // referent kind: operation
  parameter string ps214 = "sss";   // referent kind: constant (string)
  parameter logic [7:0] pv214 = 8'hab;  // typed, constant
  parameter pw214 = pv214;          // typed, ref_obj

  function automatic int sink214(int a, int b);
    return a + b;
  endfunction

  class C214;
    extern function int rd_arg214();
    extern function int rd_asgn214();
    extern function int rd_op214();
    extern function int rd_ret214();
    extern function int rd_cond214();
    extern function string rd_str214();
    extern function logic [7:0] rd_vec214();
    extern task tk_arg214();
  endclass

  // CALL ARGUMENT — the head's own position, one per referent kind.
  function int C214::rd_arg214();
    int r;
    r = sink214(pa214, pb214);
    r = sink214(pc214, pw214);
    return r;
  endfunction

  // ASSIGNMENT RHS.
  function int C214::rd_asgn214();
    int r;
    r = pb214;
    r = pc214;
    return r;
  endfunction

  // OPERATION OPERAND.
  function int C214::rd_op214();
    int r;
    r = pb214 + 1;
    r = pa214 * pc214;
    return r;
  endfunction

  // RETURN EXPRESSION (top-level and inside an operation).
  function int C214::rd_ret214();
    return pb214;
  endfunction

  // CONDITION.
  function int C214::rd_cond214();
    if (pb214 > 0) return pc214;
    return pa214;
  endfunction

  function string C214::rd_str214();
    return ps214;
  endfunction

  function logic [7:0] C214::rd_vec214();
    return pw214;
  endfunction

  // A TASK, not a function — the other half of the Task_funcs listing.
  task C214::tk_arg214();
    int r;
    r = sink214(pb214, pc214);
  endtask

endpackage

module top214;
  p214::C214 c = new();
  int x;
  initial x = c.rd_arg214();
endmodule
