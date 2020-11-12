pushd %~dp0..
set BASE_DIR=%CD%
popd

ruby -I %BASE_DIR%\lib %BASE_DIR%\lib\osgi_config\list_generator.rb %*

REM EOF
