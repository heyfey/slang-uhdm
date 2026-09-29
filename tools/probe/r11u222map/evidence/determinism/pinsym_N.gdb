set pagination off
set breakpoint pending on
break UHDM::SymbolFactory::Make if $rdx == 72 && $_memeq($rcx, "svaunit_pkg::uvm_component::record_error_tr::stream.open_recorder::label", 72)
break UHDM::SymbolFactory::add if $rdx == 72 && $_memeq($rcx, "svaunit_pkg::uvm_component::record_error_tr::stream.open_recorder::label", 72)
run
bt 14
info registers rdx rcx
kill
quit
