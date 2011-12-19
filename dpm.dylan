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
          let prefix = copy-sequence(registry-path, end: registry-path.size - 2);
          prefix = copy-sequence(path.locator-directory.locator-path, end: prefix.size)
        end;
  format-out("do-register called with path: %s\n", locator-directory(path));
  let registries = choose(registry?, user-registry-path());
  if (registries.empty?)
    format-out("Not valid user registry found\n");
  else
    let registry = registries[0];
    let registry-path = registry.locator-path;
    let prefix = copy-sequence(registry-path, end: registry-path.size - 1);
    let project-name = copy-sequence(path.locator-directory.locator-path, start: prefix.size);
    let project = concatenate("abstract://dylan", path-to-string(project-name), path.locator-name);
let generic =  merge-locators(as(<directory-locator>, "generic"), registry);
let registry-file = concatenate(path-to-string(generic.locator-path), path.locator-base);
format-out("registry => %=\n", registry);
format-out("registry-path => %=\n", registry-path);
format-out("prefix => %=\n", prefix);
format-out("project-name => %=\n", project-name);
format-out("project => %=\n", project);
format-out("merge-locators => %=\n", registry-file);
    with-open-file (stream = registry-file, direction: output:)
      write-line(stream, project);
    end;
  end;
end method do-register;

define function register (directory :: <string>)
  format-out("register called with directory: %s\n", directory);
  let dir = as(<directory-locator>, directory);
  let path 
    = if (locator-relative?(dir))
        merge-locators(dir, working-directory());
      else
        dir
      end;
  format-out("%=\n", path.locator-path);
  do(do-register,
     choose(lid-file?, directory-contents(path)));
end function register;

define function help ()
  format-out("Usage:\ndpm register path/to/project\n");
end function help;

define function main (name, arguments)
  unless(arguments.empty?)
    select (as(<symbol>, arguments[0]))
      register: => apply(register, as(<list>, copy-sequence(arguments, start: 1)));
      otherwise => help();
    end select;
  end unless;
  exit-application(0);
end function main;

// Invoke our main() function.
main(application-name(), application-arguments());
