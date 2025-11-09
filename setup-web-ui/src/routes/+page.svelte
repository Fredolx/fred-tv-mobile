<script lang="ts" module>
	import { z } from "zod/v4";

	const XTREAM = 0;
	const M3U_URL = 1;
	const M3U = 2;

	export const formSchema = z
		.object({
			name: z.string().nonempty(),
			url: z.string().optional().or(z.literal("")),
			username: z.string().optional().or(z.literal("")),
			password: z.string().optional().or(z.literal("")),
			sourceType: z.number().int(),
			file: z.any().optional(),
		})
		.refine(
			(data) => {
				if (data.sourceType === XTREAM)
					return data.username && data.username.length > 0;
				return true;
			},
			{ message: "Username is required", path: ["username"] },
		)
		.refine(
			(data) => {
				if (data.sourceType === XTREAM)
					return data.password && data.password.length > 0;
				return true;
			},
			{ message: "Password is required", path: ["password"] },
		)
		.refine(
			(data) => {
				if (data.sourceType === M3U) return data.file instanceof File;
				return true;
			},
			{ message: "File is required", path: ["file"] },
		)
		.refine(
			(data) => {
				if (data.sourceType === XTREAM || data.sourceType === M3U_URL)
					return data.url && data.url.length > 0;
				return true;
			},
			{ message: "Url is required", path: ["url"] },
		);
</script>

<script lang="ts">
	const XTREAM = 0;
	const M3U_URL = 1;
	const M3U = 2;

	import { defaults, superForm } from "sveltekit-superforms";
	import { zod4 } from "sveltekit-superforms/adapters";
	import * as Form from "$lib/components/ui/form/index.js";
	import { Input } from "$lib/components/ui/input/index.js";
	import * as NativeSelect from "$lib/components/ui/native-select/index.js";

	const form = superForm(defaults(zod4(formSchema)), {
		validators: zod4(formSchema),
		SPA: true,
		onSubmit: async ({ formData, cancel }) => {
			const name = formData.get("name") as string;
			if (!name) return cancel();

			const exists = await checkNameExists(name);
			if (exists) {
				form.errors.set({ name: ["This name already exists"] });
				return cancel();
			}
		},
	});

	let fileInput: HTMLInputElement | null = null;

	const { form: formData, enhance } = form;

	async function checkNameExists(name: string): Promise<boolean> {
		return false;
		const url = `/api/exists?name=${encodeURIComponent(name)}`;

		try {
			const response = await fetch(url);
			if (!response.ok) return false;

			const json = await response.json();
			return Boolean(json.exists);
		} catch (_) {
			return false;
		}
	}
</script>

<div class="max-w-7xl mx-auto px-4 pt-8">
	<form
		method="POST"
		enctype="multipart/form-data"
		class="w-2/3 space-y-6"
		use:enhance
	>
		<Form.Field {form} name="sourceType">
			<Form.Control>
				{#snippet children({ props })}
					<Form.Label>Source type</Form.Label>
					<NativeSelect.Root
						{...props}
						bind:value={$formData.sourceType}
					>
						<NativeSelect.Option value={XTREAM}
							>Xtream</NativeSelect.Option
						>
						<NativeSelect.Option value={M3U_URL}
							>M3U Url</NativeSelect.Option
						>
						<NativeSelect.Option value={M3U}
							>M3U File</NativeSelect.Option
						>
					</NativeSelect.Root>
				{/snippet}
			</Form.Control>
			<Form.FieldErrors />
		</Form.Field>

		<Form.Field {form} name="name">
			<Form.Control>
				{#snippet children({ props })}
					<Form.Label>Name</Form.Label>
					<Input
						{...props}
						bind:value={$formData.name}
						placeholder="My new source"
					/>
				{/snippet}
			</Form.Control>
			<Form.Description
				>This is the name of your new source</Form.Description
			>
			<Form.FieldErrors />
		</Form.Field>

		{#if $formData.sourceType === XTREAM || $formData.sourceType === M3U_URL}
			<Form.Field {form} name="url">
				<Form.Control>
					{#snippet children({ props })}
						<Form.Label>Url</Form.Label>
						<Input
							{...props}
							bind:value={$formData.url}
							placeholder="http://..."
						/>
					{/snippet}
				</Form.Control>
				<Form.Description>The url of your source</Form.Description>
				<Form.FieldErrors />
			</Form.Field>
		{/if}

		{#if $formData.sourceType === XTREAM}
			<Form.Field {form} name="username">
				<Form.Control>
					{#snippet children({ props })}
						<Form.Label>Username</Form.Label>
						<Input {...props} bind:value={$formData.username} />
					{/snippet}
				</Form.Control>
				<Form.Description>Your xtream username.</Form.Description>
				<Form.FieldErrors />
			</Form.Field>

			<Form.Field {form} name="password">
				<Form.Control>
					{#snippet children({ props })}
						<Form.Label>Password</Form.Label>
						<Input {...props} bind:value={$formData.password} />
					{/snippet}
				</Form.Control>
				<Form.Description>Your xtream password.</Form.Description>
				<Form.FieldErrors />
			</Form.Field>
		{/if}

		{#if $formData.sourceType === M3U}
			<Form.Field {form} name="file">
				<Form.Control>
					{#snippet children({ props })}
						<Form.Label>File</Form.Label>

						<div class="flex items-center gap-4">
							<button
								type="button"
								class="inline-flex items-center rounded-md bg-secondary px-4 py-2 text-sm font-medium text-secondary-foreground shadow hover:bg-secondary/80 focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
								on:click={() => fileInput.click()}
							>
								Select File
							</button>
							<span
								class="text-sm text-muted-foreground truncate max-w-[300px]"
							>
								{$formData.file
									? $formData.file.name
									: "No file selected"}
							</span>

							<input
								{...props}
								bind:this={fileInput}
								type="file"
								accept=".m3u,.m3u8"
								class="hidden"
								on:change={(e) =>
									($formData.file =
										e?.target?.files?.[0] ?? null)}
							/>
						</div>
					{/snippet}
				</Form.Control>
				<Form.Description>Select a local M3U file</Form.Description>
				<Form.FieldErrors />
			</Form.Field>
		{/if}

		<Form.Button>Submit</Form.Button>
	</form>
</div>
