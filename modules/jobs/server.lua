-- Module EV : jobs
EV.Modules.Register('jobs', {dependencies = {}, init = function(core)
 core.Jobs = core.Jobs or {}; function core.Jobs.Set(src, job, grade)
 local player = core.GetPlayer(src)
 if not player or type(job) ~= 'string' or not core.Utils.IsInteger(grade) then return false end
 local row = core.Database.Single('SELECT grade FROM ev_job_grades WHERE job_name = ? AND grade = ?', {job, grade})
 if not row then return false end
 local changed = core.Database.Update('UPDATE ev_characters SET job = ?, job_grade = ? WHERE id = ?', {job, grade, player.characterId})
 if changed ~= 1 then return false end
 player.job, player.grade = job, grade
 core.Events.Emit('jobChanged', src, job, grade)
 return true
end
end})
