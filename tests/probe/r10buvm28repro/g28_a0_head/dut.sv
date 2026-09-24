// r10buvm28 arm a0 — the corpus head in miniature:
// uvm_pkg.sv:58248 `__array = new [$bits(m_command)] (__array);` inside
// uvm_tlm_generic_payload::do_unpack, where `m_command` is a class property of
// an enum type declared with NO explicit base type.  Golden mints UINT:0.
package g28_pkg;

  typedef enum {
    G28_READ_COMMAND,
    G28_WRITE_COMMAND,
    G28_IGNORE_COMMAND
  } g28_command_e;

  class g28_payload;
    rand g28_command_e m_command;
    rand bit [63:0]    m_address;
    rand int unsigned  m_length;

    function void do_unpack();
      begin
        bit __array[] = new [64];
        __array = new [$bits(m_address)] (__array);
        m_address = { << bit { __array }};
      end
      begin
        bit __array[] = new [32];
        __array = new [$bits(m_command)] (__array);
        m_command = g28_command_e'({ << bit { __array }});
      end
      begin
        bit __array[] = new [32];
        __array = new [$bits(m_length)] (__array);
        m_length = { << bit { __array }};
      end
    endfunction
  endclass
endpackage
