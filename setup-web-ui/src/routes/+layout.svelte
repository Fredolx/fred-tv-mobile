<script lang="ts">
	import '../app.css';
	let { children } = $props();
</script>

<div class="app">
	<main>
		{@render children()}
	</main>
</div>

