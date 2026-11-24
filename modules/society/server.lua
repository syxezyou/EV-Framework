-- Module EV : society
EV.Modules.Register('society', {dependencies = {'accounts', 'jobs'}, init = function(core)
 core.Society = {enabled = true}
end})
