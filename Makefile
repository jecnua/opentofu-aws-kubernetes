fmt-all:
	terraform fmt -recursive modules/nodes/*.tf
	terraform fmt -recursive modules/controllers/*.tf
	terraform fmt -recursive example/*.tf

checks: fmt-all # 59
	tfsec .