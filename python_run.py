import sublime
import sublime_plugin
import os
class PythonRunCommand(sublime_plugin.WindowCommand):
    def run(self):
        command = 'python {} && pause'.format(
            sublime.active_window().active_view().file_name()
        )
        os.system(command)
        