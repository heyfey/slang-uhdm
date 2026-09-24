set pagination off
set print frame-arguments none
break UhdmExporter::buildEnumTs
commands
bt 4
continue
end
run
