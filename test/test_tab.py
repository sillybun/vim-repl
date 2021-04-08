def start_of_object(stripped):
	i = len(stripped) - 1
	depth = 0
	instringsingle = False
	instringdouble = False
	while i >= 0:
		if not instringsingle and not instringdouble:
			if stripped[i] in [')', ']', '}']:
				depth += 1
				i-=1
				continue
			if stripped[i] in ['(', '[', '{']:
				depth -= 1
				if depth < 0:
					break
				i-=1
				continue
			if stripped[i] == '"':
				instringdouble = True
				i-=1
				continue
			if stripped[i] == '\'':
				instringsingle = True
				i-=1
				continue
			if stripped[i] in [' ', '+', '-', '*', '/', '=', ':', ',', '&', '>', '<'] and depth == 0:
				break
		elif instringsingle:
			if stripped[i] == '\'' and (i == 0 or stripped[i-1] != '\\'):
				instringsingle = False
				i-=1
				continue
		else:
			if stripped[i] == '"' and (i == 0 or stripped[i-1] != '\\'):
				instringdouble = False
				i-=1
				continue
		i-=1
	return i + 1
