module: dpm
synopsis: Dylan Package Manager
author: Alfredo Beaumont <alfredo.beaumont@gmail.com>
copyright: See License.txt

define function lid-file? (locator :: <locator>)
  file-type(locator) = #"file" 
    & as-lowercase(locator-extension(locator)) = "lid";
end function lid-file?;

define method do-register (path :: <file-locator>)
  local method registry?(registry-locator :: <directory-locator>)
          let registry-path = registry-locator.locator-path;
          let prefix = copy-sequence(registry-path,
                                     end: registry-path.size - 2);
          prefix = copy-sequence(path.locator-directory.locator-path,
                                 end: prefix.size);
        end;
  let registries = choose(registry?, user-registry-path());
  if (registries.empty?)
    format-out("Not valid user registry found\n");
  else
    let registry = registries[0];
    let registry-path = registry.locator-path;
    let prefix = copy-sequence(registry-path, end: registry-path.size - 1);
    let project-name = copy-sequence(path.locator-directory.locator-path,
                                     start: prefix.size);
    let project = concatenate("abstract://dylan", 
                              path-to-string(project-name),
                              path.locator-name);
    let generic =  merge-locators(as(<directory-locator>, "generic"),
                                  registry);
    let registry-file = concatenate(path-to-string(generic.locator-path),
                                    path.locator-base);
    with-open-file (stream = registry-file, direction: output:)
      write-line(stream, project);
    end;
  end;
end method do-register;

define function register (directory :: <string>)
  let dir = as(<directory-locator>, directory);
  let path 
    = if (locator-relative?(dir))
        merge-locators(dir, working-directory());
      else
        dir
      end;
  do(do-register,
     choose(lid-file?, directory-contents(path)));
end function register;

define abstract class <command> (<object>)
  constant slot args :: <simple-object-vector>, required-init-keyword: args:;
end class;

define class <register> (<command>)
end class;

define class <install> (<command>)
end class;

define class <help> (<command>)
end class;

define class <invalid-command> (<command>)
end class;

define constant command-table = make(<table>);

define function register-commands ()
  command-table[register:] := <register>;
  command-table[install:] := <install>;
  command-table[help:] := <help>;
end function register-commands;

define inline function find-command (command :: <symbol>)
  command-table[command];
end function find-command;

define generic run (command :: <command>) => ();

define method run (command :: <register>) => ()
  if (command.args.size ~= 1)
    help(command);
  else
    register(command.args.first);
  end;
end method run;

define method run (command :: <install>) => ()
  format-out("Not implemented yet. Sorry O:-)\n");
end method run;

define method run (command :: <help>) => ()
  help(command);
end method run;

define method run (command :: <command>) => ()
  help(command);
end method run;

define generic help (comand :: false-or(<command>)) => ();

define method help (command :: <register>) => ()
  format-out("dpm register project\n\n");
  format-out("Register task adds PROJECT to registry.\n");
  format-out("PROJECT may be either a LID file or a directory containing one\n");
end method help;

define method help (command :: <install>) => ()
  format-out("Not implemented yet. Sorry O:-)\n");
end method help;

define method help (command :: <help>) => ()
  if (command.args.empty?)
      format-out("Try with: dpm help $TASK\n");
  else
      block ()
        help(make(find-command(as(<symbol>, command.args.first)),
                  args: copy-sequence(command.args, start: 1)));
      exception (condition :: <simple-error>)
        help(make(<invalid-command>, args: command.args));
      end block;
  end;
end method help;

define method help (command :: <command>) => ()
  format-out("%s command doesn't exit\n", command.args.first)
end method help;

define method help (command :: singleton(#f)) => ()
  format-out("Dylan Package Manager is a tool for working with Dylan projects\n");
  help-tasks();
end method help;

define function help-tasks () => ()
  format-out("\nSeveral tasks are available:\n");
  format-out("register  Add a project to a register\n");
  format-out("install   Install a project\n");
  format-out("\nRun dpm help $TASK for details.\n");
end function help-tasks;

define function main (name, args)
  register-commands();
  if(args.empty?)
    help(#f);
  else 
    block ()
      run(make(find-command(as(<symbol>, args.first)),
               args: copy-sequence(args, start: 1)));
    exception (condition :: <simple-error>)
      help(make(<invalid-command>, args: args));
    end block;
  end if;
  exit-application(0);
end function main;

block ()
  main(application-name(), application-arguments());
end;
